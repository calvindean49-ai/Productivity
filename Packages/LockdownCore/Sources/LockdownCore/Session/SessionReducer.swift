import Foundation

/// Pure transition function. No clocks, no timers, no I/O: every event
/// carries its own timestamp and every side effect comes back as data.
public struct SessionReducer: Sendable {
    public var config: LockdownConfig

    public init(config: LockdownConfig) {
        self.config = config
    }

    public func reduce(_ state: SessionState, _ event: SessionEvent) -> (SessionState, [SessionEffect]) {
        var s = state
        var fx: [SessionEffect] = []

        switch (state.phase, event) {

        // MARK: start / cancel

        case (.idle, .startRequested(let minutes, let origin, let at)):
            s = SessionState()
            s.phase = .arming
            s.session = ActiveSession(startedAt: at, minutes: max(1, minutes), origin: origin)
            fx = [.startMotion, .startKeepalive, .persist]

        case (.arming, .cancelled):
            s = SessionState()
            fx = [.stopMotion, .stopAudio, .persist, .sessionEnded(.cancelled)]

        // MARK: posture & time

        case (_, .posture(let anchored, let at)):
            guard state.phase.isActive else { return (state, []) }
            if anchored != state.anchored || state.postureSince == nil {
                s.anchored = anchored
                s.postureSince = at
            }
            let (s2, fx2) = evaluate(s, at: at)
            return (s2, fx2)

        case (_, .tick(let at)):
            guard state.phase.isActive else { return (state, []) }
            return evaluate(s, at: at)

        // MARK: appeal

        case (.guarding, .earlyExitRequested(let at)), (.alarming, .earlyExitRequested(let at)):
            s.appealReturnPhase = state.phase
            s.appealStartedAt = at
            s.phase = .appeal
            fx = [.persist]

        case (.appeal, .appealPassed(let at)):
            let duration = state.alarmStartedAt.map { at.timeIntervalSince($0) } ?? 0
            let dep = departure(state, kind: .earlyExit, at: at, duration: duration)
            return end(s, reason: .earlyExit, at: at, departure: dep)

        case (.appeal, .appealAbandoned):
            s.phase = state.appealReturnPhase ?? .guarding
            s.appealReturnPhase = nil
            s.appealStartedAt = nil
            fx = [.persist]

        // MARK: external

        case (.guarding, .aetherSessionEnded(let at)),
             (.alarming, .aetherSessionEnded(let at)),
             (.appeal, .aetherSessionEnded(let at)):
            return end(s, reason: .aetherStopped, at: at, departure: nil)

        case (_, .aetherLinked(let link, _)):
            guard state.phase.isActive, s.session != nil else { return (state, []) }
            s.session?.aether = link
            fx = [.persist]

        case (.guarding, .sensorStalled(let at)), (.alarming, .sensorStalled(let at)):
            guard !state.stallReported else { return (state, []) }
            s.stallReported = true
            let dep = departure(state, kind: .sensorStall, at: at, duration: 0)
            fx = [
                .recordDeparture(dep),
                .notify(title: "Lockdown lost its sensor",
                        body: "Motion stopped arriving. Open the app to re-arm."),
                .persist,
            ]

        case (_, .panic(let at)):
            guard state.phase.isActive else { return (state, []) }
            let dep = departure(state, kind: .panic, at: at, duration: 0)
            return end(s, reason: .panic, at: at, departure: dep)

        case (.ending, .cleanupDone):
            s = SessionState()
            fx = [.persist]

        default:
            return (state, [])
        }

        return (s, fx)
    }

    // MARK: - time-based evaluation

    private func evaluate(_ state: SessionState, at now: Date) -> (SessionState, [SessionEffect]) {
        var s = state
        var fx: [SessionEffect] = []
        guard let session = state.session else { return (state, []) }
        let held = state.postureHeld(at: now)

        switch state.phase {
        case .arming:
            if state.anchored && held >= config.graceStart {
                s.phase = .guarding
                fx.append(.scheduleBackupNotifications(endsAt: session.endsAt))
                if session.aether == .unlinked {
                    s.session?.aether = .pending
                    fx.append(.postAetherStart(session))
                }
                fx.append(.persist)
            }

        case .guarding:
            if now >= session.endsAt {
                return end(s, reason: .timerExpired, at: now, departure: nil)
            }
            if !state.anchored && held >= config.alarmDelay {
                s.phase = .alarming
                s.alarmStartedAt = now
                fx = [.playAlarm, .persist]
            }

        case .alarming:
            let alarmFor = state.alarmStartedAt.map { now.timeIntervalSince($0) } ?? 0
            if now >= session.endsAt {
                let dep = departure(state, kind: .pickup, at: now, duration: alarmFor)
                return end(s, reason: .timerExpired, at: now, departure: dep)
            }
            if alarmFor >= config.alarmTimeoutSeconds {
                let dep = departure(state, kind: .alarmTimeout, at: now, duration: alarmFor)
                return end(s, reason: .alarmTimeout, at: now, departure: dep)
            }
            if state.anchored && held >= config.graceReturn {
                s.phase = .guarding
                s.alarmStartedAt = nil
                s.session?.pickups += 1
                let dep = departure(state, kind: .pickup, at: now, duration: alarmFor)
                fx = [.stopAlarm, .recordDeparture(dep), .persist]
            }

        case .appeal:
            if now >= session.endsAt {
                return end(s, reason: .timerExpired, at: now, departure: nil)
            }

        case .idle, .ending:
            break
        }
        return (s, fx)
    }

    private func departure(_ state: SessionState, kind: DepartureKind, at: Date, duration: TimeInterval) -> Departure {
        Departure(
            sessionId: state.session?.id ?? UUID(),
            at: at,
            kind: kind,
            durationSeconds: max(0, duration)
        )
    }

    private func end(_ state: SessionState, reason: EndReason, at now: Date, departure: Departure?) -> (SessionState, [SessionEffect]) {
        var s = state
        s.phase = .ending(reason)
        s.alarmStartedAt = nil
        s.appealStartedAt = nil
        s.appealReturnPhase = nil

        var fx: [SessionEffect] = [.stopAlarm, .stopAudio, .stopMotion, .cancelBackupNotifications]
        if let departure { fx.append(.recordDeparture(departure)) }
        if let session = state.session, session.aether == .started {
            let shouldStop: Bool
            switch reason {
            case .timerExpired, .alarmTimeout: shouldStop = true
            case .earlyExit, .panic: shouldStop = config.stopAetherOnEarlyExit
            case .aetherStopped, .cancelled: shouldStop = false
            }
            if shouldStop {
                let minutes = Int((now.timeIntervalSince(session.startedAt) / 60).rounded())
                fx.append(.postAetherStop(session, durationMinutes: max(1, minutes)))
            }
        }
        fx.append(.persist)
        fx.append(.sessionEnded(reason))
        return (s, fx)
    }
}
