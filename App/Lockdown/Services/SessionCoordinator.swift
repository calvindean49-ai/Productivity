import Combine
import Foundation
import LockdownCore
import SwiftUI
import UIKit

enum StartOutcome: Equatable {
    case started
    case refused(String)
}

/// Runs the pure reducer and executes its effects against the real phone.
/// Everything observable by the UI lives here.
@MainActor
final class SessionCoordinator: ObservableObject {
    @Published private(set) var state: SessionState
    @Published var config: LockdownConfig {
        didSet {
            settings.saveConfig(config)
            reducer = SessionReducer(config: config)
            classifier.update(config: config)
            aether.config = config
        }
    }
    @Published private(set) var posture: Posture?
    @Published private(set) var samplesPerSecond: Double = 0
    @Published private(set) var lastEnd: EndReason?
    @Published var pendingDeparture: Departure?
    @Published private(set) var departures: [Departure] = []
    @Published private(set) var lastError: String?
    @Published var keepScreenOn: Bool {
        didSet { settings.keepScreenOn = keepScreenOn; applyIdleTimer() }
    }

    let aether: AetherService
    private let settings: SettingsStore
    private let departureLog: FileDepartureLog
    private let motion: MotionService
    let audio: AudioService
    private let notifications: NotificationService

    private var reducer: SessionReducer
    private var classifier: StillnessClassifier
    private var ticker: Timer?
    private var lastSampleAt: Date?
    private var sampleCount = 0
    private var sampleWindowStart = Date()
    private var secondsSincePoll: TimeInterval = 0
    private var restored = false
    private var streamingOnly = false   // Calibration: motion without a session
    private var cancellables: Set<AnyCancellable> = []

    init(settings: SettingsStore, departureLog: FileDepartureLog, aether: AetherService,
         motion: MotionService, audio: AudioService, notifications: NotificationService) {
        self.settings = settings
        self.departureLog = departureLog
        self.aether = aether
        self.motion = motion
        self.audio = audio
        self.notifications = notifications
        let cfg = settings.loadConfig()
        self.config = cfg
        self.reducer = SessionReducer(config: cfg)
        self.classifier = StillnessClassifier(config: cfg)
        self.state = .idle
        self.keepScreenOn = settings.keepScreenOn
        self.departures = (try? departureLog.all()) ?? []
        // Views observe the coordinator only; surface Aether status changes through it.
        aether.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - lifecycle

    /// Called when the UI first appears. Resumes a session cut short by a
    /// crash or a swipe-kill: the phone has to be placed again.
    func restoreIfNeeded() {
        guard !restored else { return }
        restored = true
        notifications.requestAuthorization()
        sweepUnsentDepartures()
        guard var saved = settings.loadState(), saved.phase.isActive, let session = saved.session else {
            settings.saveState(.idle)
            return
        }
        let now = Date()
        if case .ending = saved.phase {
            settings.saveState(.idle)
            return
        }
        guard session.endsAt > now else {
            lastEnd = .timerExpired
            settings.saveState(.idle)
            return
        }
        saved.phase = .arming
        saved.anchored = false
        saved.postureSince = nil
        saved.alarmStartedAt = nil
        saved.appealStartedAt = nil
        saved.appealReturnPhase = nil
        // A start that was in flight when the process died is unknown; asking
        // again is safe because Aether answers 409 if it did go through.
        if saved.session?.aether == .pending { saved.session?.aether = .unlinked }
        state = saved
        execute([.startMotion, .startKeepalive, .persist])
        startTicker()
    }

    /// Departures the user never answered and that never reached the outbox
    /// (a kill mid-sheet, a bug) go to Aether with the honest placeholder.
    private func sweepUnsentDepartures() {
        for d in departures where d.leftFor == nil && !d.synced && !aether.isQueued(departureId: d.id) {
            aether.enqueueDeparture(d)
        }
    }

    func scenePhaseChanged(_ phase: ScenePhase) {
        switch phase {
        case .active:
            restoreIfNeeded()
            audio.resumeIfNeeded()
            if state.phase.isActive && !motion.isRunning { execute([.startMotion]) }
            Task { await drainOutbox() }
        case .background:
            // The documented workaround for motion updates stalling in the background.
            if state.phase.isActive || streamingOnly { motion.restart() }
        default:
            break
        }
    }

    // MARK: - commands

    func start(minutes: Int, origin: SessionOrigin) -> StartOutcome {
        guard !state.phase.isActive else { return .refused("A session is already running.") }
        guard motion.isAvailable else { return .refused("This device has no motion sensor.") }
        if audio.isExternalRoute {
            return .refused("Disconnect headphones or Bluetooth audio first, or the alarm will play there.")
        }
        if Double(audio.outputVolume) < config.minOutputVolume {
            let pct = Int((config.minOutputVolume * 100).rounded())
            return .refused("Turn the volume up to at least \(pct)% so the alarm can be heard.")
        }
        stopStreaming()
        lastEnd = nil
        lastError = nil
        dispatch(.startRequested(minutes: minutes, origin: origin, at: Date()))
        startTicker()
        return .started
    }

    func cancelArming() { dispatch(.cancelled(at: Date())) }
    func requestEarlyExit() { dispatch(.earlyExitRequested(at: Date())) }
    func abandonAppeal() { dispatch(.appealAbandoned(at: Date())) }
    func panic() { dispatch(.panic(at: Date())) }

    /// True if the appeal was accepted and the session is ending.
    @discardableResult
    func submitAppeal(typed: String) -> Bool {
        let now = Date()
        guard state.appealPasses(typed: typed, at: now, config: config) else { return false }
        dispatch(.appealPassed(at: now))
        return true
    }

    func answerDeparture(_ departure: Departure, leftFor: String?, app: String?) {
        var d = departure
        d.leftFor = leftFor?.trimmingCharacters(in: .whitespacesAndNewlines)
        d.app = app?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        try? departureLog.update(d)
        replace(d)
        if !aether.isQueued(departureId: d.id) { aether.enqueueDeparture(d) }
        if pendingDeparture?.id == d.id { pendingDeparture = nil }
        Task { await drainOutbox() }
    }

    /// A departure logged outside any session (Shortcut, URL).
    func logStandaloneDeparture(leftFor: String, app: String?) {
        let d = Departure(sessionId: state.session?.id ?? UUID(), at: Date(), kind: .pickup,
                          leftFor: leftFor, app: app)
        try? departureLog.append(d)
        departures.append(d)
        aether.enqueueDeparture(d)
        Task { await drainOutbox() }
    }

    // MARK: - calibration streaming

    var isStreaming: Bool { streamingOnly }

    func startStreaming() {
        guard !state.phase.isActive else { return }
        streamingOnly = true
        classifier.reset()
        try? audio.startKeepalive()
        motion.start(handler: { [weak self] s in self?.handle(sample: s) })
    }

    func stopStreaming() {
        guard streamingOnly else { return }
        streamingOnly = false
        motion.stop()
        audio.stopAll()
        posture = nil
    }

    // MARK: - dispatch

    func dispatch(_ event: SessionEvent) {
        let (next, effects) = reducer.reduce(state, event)
        let changed = next != state
        if changed { state = next }   // avoid re-publishing 20x/s on unchanged posture
        if !effects.isEmpty {
            execute(effects)
        }
        if case .ending = state.phase {
            dispatch(.cleanupDone(at: Date()))
            stopTicker()
            applyIdleTimer()
        }
    }

    private func execute(_ effects: [SessionEffect]) {
        for e in effects {
            switch e {
            case .startMotion:
                classifier.reset()
                lastSampleAt = nil
                motion.start(handler: { [weak self] s in self?.handle(sample: s) })
                applyIdleTimer()
            case .stopMotion:
                motion.stop()
                posture = nil
            case .startKeepalive:
                do { try audio.startKeepalive() } catch { lastError = "Audio failed: \(error)" }
            case .stopAudio:
                audio.stopAll()
            case .playAlarm:
                audio.playAlarm()
            case .stopAlarm:
                audio.stopAlarm()
            case .persist:
                settings.saveState(state)
            case .recordDeparture(let d):
                try? departureLog.append(d)
                departures.append(d)
                switch d.kind {
                case .pickup, .earlyExit:
                    setPending(d)
                case .sensorStall, .alarmTimeout, .panic:
                    aether.enqueueDeparture(d)
                }
            case .postAetherStart(let session):
                Task { [weak self] in
                    guard let self else { return }
                    let link = await self.aether.startSitting()
                    if self.state.session?.id == session.id {
                        self.dispatch(.aetherLinked(link, at: Date()))
                    } else if link == .started {
                        // The phone session ended while the start was in flight.
                        // Do not leave Aether holding a sitting nobody is doing.
                        let minutes = Int((Date().timeIntervalSince(session.startedAt) / 60).rounded())
                        self.aether.enqueueStop(durationMinutes: max(1, minutes))
                        await self.drainOutbox()
                    }
                }
            case .postAetherStop(_, let minutes):
                aether.enqueueStop(durationMinutes: minutes)
                Task { await drainOutbox() }
            case .scheduleBackupNotifications(let endsAt):
                notifications.scheduleBackups(endsAt: endsAt)
            case .cancelBackupNotifications:
                notifications.cancelBackups()
            case .notify(let title, let body):
                notifications.post(title: title, body: body)
            case .sessionEnded(let reason):
                lastEnd = reason
                // `pendingDeparture` is left alone: the sheet stays up over the
                // home screen so an early exit or last pickup can still be
                // explained. Skip sends the placeholder.
                Task { await drainOutbox() }
            }
        }
    }

    // MARK: - samples and ticks

    private func handle(sample: MotionSample) {
        let now = Date()
        lastSampleAt = now
        sampleCount += 1
        let elapsed = now.timeIntervalSince(sampleWindowStart)
        if elapsed >= 1 {
            samplesPerSecond = Double(sampleCount) / elapsed
            sampleCount = 0
            sampleWindowStart = now
        }
        let p = classifier.ingest(sample)
        posture = p
        trace?(sample, p)
        if state.phase.isActive {
            dispatch(.posture(anchored: p.anchored, at: now))
        }
    }

    /// Calibration hook: receives every sample while set.
    var trace: ((MotionSample, Posture) -> Void)?

    private func startTicker() {
        stopTicker()
        secondsSincePoll = 0
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard state.phase.isActive else { stopTicker(); return }
        let now = Date()
        dispatch(.tick(at: now))
        guard state.phase.isActive else { return }

        // Stall watchdog.
        if state.phase == .guarding || state.phase == .alarming, let last = lastSampleAt {
            let gap = now.timeIntervalSince(last)
            if gap >= config.stallFailSeconds {
                dispatch(.sensorStalled(at: now))
            } else if gap >= config.stallRestartSeconds {
                motion.restart()
            }
        }

        // Aether poll while linked.
        secondsSincePoll += 1
        if secondsSincePoll >= config.aetherPollSeconds {
            secondsSincePoll = 0
            if let link = state.session?.aether, link == .started || link == .adopted {
                Task { [weak self] in
                    guard let self else { return }
                    if let active = await self.aether.pollActive(), active == false {
                        self.dispatch(.aetherSessionEnded(at: Date()))
                    }
                    await self.drainOutbox()
                }
            }
        }
    }

    private func drainOutbox() async {
        let synced = await aether.drain()
        guard !synced.isEmpty else { return }
        for id in synced {
            if var d = departures.first(where: { $0.id == id }) {
                d.synced = true
                try? departureLog.update(d)
                replace(d)
            }
        }
    }

    /// Show one departure at a time. An unanswered one that gets displaced is
    /// sent with the placeholder rather than lost.
    private func setPending(_ d: Departure) {
        if let previous = pendingDeparture, previous.id != d.id, previous.leftFor == nil,
           !aether.isQueued(departureId: previous.id) {
            aether.enqueueDeparture(previous)
        }
        pendingDeparture = d
    }

    private func replace(_ d: Departure) {
        if let i = departures.firstIndex(where: { $0.id == d.id }) {
            departures[i] = d
        } else {
            departures.append(d)
        }
    }

    private func applyIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = state.phase.isActive && keepScreenOn
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
