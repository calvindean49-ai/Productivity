import XCTest
@testable import LockdownCore

final class SessionReducerTests: XCTestCase {
    let config = LockdownConfig.default
    lazy var reducer = SessionReducer(config: config)
    let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    func at(_ s: TimeInterval) -> Date { t0.addingTimeInterval(s) }

    /// Feed a sequence of events and return the final state and every effect.
    func run(_ events: [SessionEvent], from state: SessionState = .idle) -> (SessionState, [SessionEffect]) {
        var s = state
        var all: [SessionEffect] = []
        for e in events {
            let (s2, fx) = reducer.reduce(s, e)
            s = s2
            all += fx
        }
        return (s, all)
    }

    /// idle -> arming -> guarding by holding the phone anchored for graceStart.
    func guardingState() -> SessionState {
        let (s, _) = run([
            .startRequested(minutes: 50, origin: .manual, at: at(0)),
            .posture(anchored: true, at: at(1)),
            .tick(at: at(1 + config.graceStart)),
        ])
        XCTAssertEqual(s.phase, .guarding)
        return s
    }

    func testStartEntersArmingWithMotionAndKeepalive() {
        let (s, fx) = run([.startRequested(minutes: 25, origin: .nfc, at: at(0))])
        XCTAssertEqual(s.phase, .arming)
        XCTAssertEqual(s.session?.minutes, 25)
        XCTAssertEqual(s.session?.origin, .nfc)
        XCTAssertEqual(s.session?.endsAt, at(25 * 60))
        XCTAssertEqual(fx, [.startMotion, .startKeepalive, .persist])
    }

    func testStartIgnoredWhileActive() {
        let g = guardingState()
        let (s, fx) = reducer.reduce(g, .startRequested(minutes: 10, origin: .manual, at: at(100)))
        XCTAssertEqual(s, g)
        XCTAssertTrue(fx.isEmpty)
    }

    func testCancelWhileArmingIsFree() {
        let (s, fx) = run([
            .startRequested(minutes: 50, origin: .manual, at: at(0)),
            .cancelled(at: at(2)),
        ])
        XCTAssertEqual(s.phase, .idle)
        XCTAssertNil(s.session)
        XCTAssertFalse(fx.contains { if case .recordDeparture = $0 { return true } else { return false } })
        XCTAssertTrue(fx.contains(.sessionEnded(.cancelled)))
    }

    func testArmingNeedsGraceBeforeGuarding() {
        let (early, _) = run([
            .startRequested(minutes: 50, origin: .manual, at: at(0)),
            .posture(anchored: true, at: at(1)),
            .tick(at: at(1 + config.graceStart - 0.5)),
        ])
        XCTAssertEqual(early.phase, .arming)

        let (s, fx) = run([.tick(at: at(1 + config.graceStart))], from: early)
        XCTAssertEqual(s.phase, .guarding)
        XCTAssertTrue(fx.contains(.scheduleBackupNotifications(endsAt: at(50 * 60))))
        XCTAssertEqual(s.session?.aether, .pending)
        XCTAssertTrue(fx.contains { if case .postAetherStart = $0 { return true } else { return false } })
    }

    func testFlippingPostureResetsGrace() {
        let (s, _) = run([
            .startRequested(minutes: 50, origin: .manual, at: at(0)),
            .posture(anchored: true, at: at(1)),
            .posture(anchored: false, at: at(3)),
            .posture(anchored: true, at: at(4)),
            .tick(at: at(4 + config.graceStart - 1)),
        ])
        XCTAssertEqual(s.phase, .arming)
    }

    func testBriefBumpDoesNotAlarm() {
        let g = guardingState()
        let (s, fx) = run([
            .posture(anchored: false, at: at(100)),
            .posture(anchored: true, at: at(100.5)),
            .tick(at: at(103)),
        ], from: g)
        XCTAssertEqual(s.phase, .guarding)
        XCTAssertFalse(fx.contains(.playAlarm))
    }

    func testPickupAlarmsThenSettlesAndRecordsDeparture() {
        let g = guardingState()
        let (alarming, fx1) = run([
            .posture(anchored: false, at: at(100)),
            .tick(at: at(100 + config.alarmDelay)),
        ], from: g)
        XCTAssertEqual(alarming.phase, .alarming)
        XCTAssertTrue(fx1.contains(.playAlarm))
        XCTAssertEqual(alarming.alarmStartedAt, at(100 + config.alarmDelay))

        let (s, fx2) = run([
            .posture(anchored: true, at: at(130)),
            .tick(at: at(130 + config.graceReturn)),
        ], from: alarming)
        XCTAssertEqual(s.phase, .guarding)
        XCTAssertEqual(s.session?.pickups, 1)
        XCTAssertTrue(fx2.contains(.stopAlarm))
        guard let dep = fx2.compactMap({ e -> Departure? in
            if case .recordDeparture(let d) = e { return d } else { return nil }
        }).first else { return XCTFail("no departure recorded") }
        XCTAssertEqual(dep.kind, .pickup)
        XCTAssertEqual(dep.durationSeconds, 130 + config.graceReturn - (100 + config.alarmDelay), accuracy: 0.001)
        XCTAssertEqual(dep.sessionId, g.session?.id)
    }

    func testTimerExpiryEndsAndStopsAetherWhenPhoneStartedIt() {
        var g = guardingState()
        g.session?.aether = .started
        let (s, fx) = run([.tick(at: at(50 * 60))], from: g)
        XCTAssertEqual(s.phase, .ending(.timerExpired))
        XCTAssertTrue(fx.contains(.stopAudio))
        XCTAssertTrue(fx.contains(.stopMotion))
        XCTAssertTrue(fx.contains(.cancelBackupNotifications))
        XCTAssertTrue(fx.contains(.sessionEnded(.timerExpired)))
        let stop = fx.first { if case .postAetherStop = $0 { return true } else { return false } }
        XCTAssertNotNil(stop)
        if case .postAetherStop(_, let minutes)? = stop { XCTAssertEqual(minutes, 50) }

        let (idle, _) = run([.cleanupDone(at: at(3001))], from: s)
        XCTAssertEqual(idle, .idle)
    }

    func testTimerExpiryDoesNotStopAdoptedSitting() {
        var g = guardingState()
        g.session?.aether = .adopted
        let (_, fx) = run([.tick(at: at(50 * 60))], from: g)
        XCTAssertFalse(fx.contains { if case .postAetherStop = $0 { return true } else { return false } })
    }

    func testEarlyExitGoesThroughAppeal() {
        let g = guardingState()
        let (appeal, _) = run([.earlyExitRequested(at: at(200))], from: g)
        XCTAssertEqual(appeal.phase, .appeal)
        XCTAssertEqual(appeal.appealReturnPhase, .guarding)
        XCTAssertEqual(appeal.appealCooldownRemaining(at: at(230), config: config), config.appealCooldownSeconds - 30, accuracy: 0.001)
        XCTAssertFalse(appeal.appealPasses(typed: "nope", at: at(230), config: config))
        XCTAssertTrue(appeal.appealPasses(typed: config.appealPhrase, at: at(230), config: config))
        XCTAssertTrue(appeal.appealPasses(typed: "", at: at(200 + config.appealCooldownSeconds), config: config))

        let (back, _) = run([.appealAbandoned(at: at(240))], from: appeal)
        XCTAssertEqual(back.phase, .guarding)

        var linked = appeal
        linked.session?.aether = .started
        let (s, fx) = run([.appealPassed(at: at(250))], from: linked)
        XCTAssertEqual(s.phase, .ending(.earlyExit))
        let dep = fx.compactMap { e -> Departure? in
            if case .recordDeparture(let d) = e { return d } else { return nil }
        }.first
        XCTAssertEqual(dep?.kind, .earlyExit)
        XCTAssertFalse(fx.contains { if case .postAetherStop = $0 { return true } else { return false } },
                       "stopAetherOnEarlyExit defaults to false")
    }

    func testEarlyExitStopsAetherWhenConfigured() {
        var cfg = config
        cfg.stopAetherOnEarlyExit = true
        reducer = SessionReducer(config: cfg)
        var g = guardingState()
        g.session?.aether = .started
        let (_, fx) = run([.earlyExitRequested(at: at(200)), .appealPassed(at: at(300))], from: g)
        XCTAssertTrue(fx.contains { if case .postAetherStop = $0 { return true } else { return false } })
    }

    func testAppealFromAlarmingReturnsToAlarming() {
        let g = guardingState()
        let (alarming, _) = run([
            .posture(anchored: false, at: at(100)),
            .tick(at: at(102)),
        ], from: g)
        XCTAssertEqual(alarming.phase, .alarming)
        let (appeal, _) = run([.earlyExitRequested(at: at(103))], from: alarming)
        let (back, _) = run([.appealAbandoned(at: at(104))], from: appeal)
        XCTAssertEqual(back.phase, .alarming)
        XCTAssertEqual(back.alarmStartedAt, alarming.alarmStartedAt)
    }

    func testAlarmTimeoutEndsSession() {
        let g = guardingState()
        let (s, fx) = run([
            .posture(anchored: false, at: at(100)),
            .tick(at: at(102)),
            .tick(at: at(102 + config.alarmTimeoutSeconds)),
        ], from: g)
        XCTAssertEqual(s.phase, .ending(.alarmTimeout))
        XCTAssertTrue(fx.contains(.stopAlarm))
        XCTAssertEqual(fx.compactMap { e -> DepartureKind? in
            if case .recordDeparture(let d) = e { return d.kind } else { return nil }
        }, [.alarmTimeout])
    }

    func testAetherEndedStopsPhoneSessionWithoutPostingStop() {
        var g = guardingState()
        g.session?.aether = .adopted
        let (s, fx) = run([.aetherSessionEnded(at: at(300))], from: g)
        XCTAssertEqual(s.phase, .ending(.aetherStopped))
        XCTAssertFalse(fx.contains { if case .postAetherStop = $0 { return true } else { return false } })
    }

    func testAetherEndedWhileArmingEndsToo() {
        let (arming, _) = run([.startRequested(minutes: 50, origin: .aether, at: at(0))])
        XCTAssertEqual(arming.phase, .arming)
        let (s, fx) = run([.aetherSessionEnded(at: at(5))], from: arming)
        XCTAssertEqual(s.phase, .ending(.aetherStopped))
        XCTAssertTrue(fx.contains(.stopMotion))
    }

    func testAlarmTimeoutStillAppliesDuringAppeal() {
        let g = guardingState()
        let (appeal, fx1) = run([
            .posture(anchored: false, at: at(100)),
            .tick(at: at(102)),
            .earlyExitRequested(at: at(103)),
        ], from: g)
        XCTAssertEqual(appeal.phase, .appeal)
        XCTAssertFalse(fx1.contains(.stopAlarm), "alarm keeps sounding through the appeal")
        let (s, fx2) = run([.tick(at: at(102 + config.alarmTimeoutSeconds))], from: appeal)
        XCTAssertEqual(s.phase, .ending(.alarmTimeout))
        XCTAssertTrue(fx2.contains(.stopAlarm))
    }

    func testAetherLinkedUpdatesSession() {
        let g = guardingState()
        let (s, _) = run([.aetherLinked(.adopted, at: at(10))], from: g)
        XCTAssertEqual(s.session?.aether, .adopted)
        let (idle, _) = reducer.reduce(.idle, .aetherLinked(.started, at: at(10)))
        XCTAssertEqual(idle, .idle)
    }

    func testSensorStallReportedOnce() {
        let g = guardingState()
        let (s, fx) = run([.sensorStalled(at: at(50)), .sensorStalled(at: at(60))], from: g)
        XCTAssertEqual(s.phase, .guarding)
        XCTAssertEqual(fx.filter { if case .recordDeparture = $0 { return true } else { return false } }.count, 1)
        XCTAssertEqual(fx.filter { if case .notify = $0 { return true } else { return false } }.count, 1)
    }

    func testPanicEndsFromAnyActivePhase() {
        let g = guardingState()
        let (s, fx) = run([.panic(at: at(50))], from: g)
        XCTAssertEqual(s.phase, .ending(.panic))
        XCTAssertTrue(fx.contains(.stopAlarm))
        let (idle, fx2) = reducer.reduce(.idle, .panic(at: at(50)))
        XCTAssertEqual(idle, .idle)
        XCTAssertTrue(fx2.isEmpty)
    }

    func testPostureIgnoredWhenIdle() {
        let (s, fx) = reducer.reduce(.idle, .posture(anchored: true, at: at(1)))
        XCTAssertEqual(s, .idle)
        XCTAssertTrue(fx.isEmpty)
    }

    func testStateRoundTripsThroughJSON() throws {
        let g = guardingState()
        let data = try JSONCoding.encoder.encode(g)
        let back = try JSONCoding.decoder.decode(SessionState.self, from: data)
        XCTAssertEqual(back, g)
    }
}
