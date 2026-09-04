import AVFoundation
import Foundation
import UIKit

/// Owns the audio session, the silent keepalive and the alarm.
///
/// `.playback` ignores the Ring/Silent switch and, with the `audio`
/// background mode, keeps the process alive while the phone is locked. That
/// is what lets Core Motion keep delivering. Volume cannot be set from code;
/// it can only be checked, which `outputVolume` is for.
final class AudioService {
    private var keepalive: AVAudioPlayer?
    private var alarm: AVAudioPlayer?
    private(set) var alarmActive = false
    private(set) var keepaliveActive = false
    private var observers: [NSObjectProtocol] = []

    init() {
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] n in
            self?.handleInterruption(n)
        })
        observers.append(nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.resumeIfNeeded()
        })
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    var outputVolume: Float { AVAudioSession.sharedInstance().outputVolume }

    /// True when sound would leave through headphones, Bluetooth, AirPlay
    /// or anything other than the phone's own speaker.
    var isExternalRoute: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains { out in
            switch out.portType {
            case .builtInSpeaker, .builtInReceiver: return false
            default: return true
            }
        }
    }

    func startKeepalive() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
        if keepalive == nil {
            let p = try AVAudioPlayer(contentsOf: try ToneFactory.silenceURL())
            p.numberOfLoops = -1
            p.volume = 0.01
            p.prepareToPlay()
            keepalive = p
        }
        keepalive?.play()
        keepaliveActive = true
    }

    func playAlarm() {
        let session = AVAudioSession.sharedInstance()
        // Drop mixWithOthers so the alarm interrupts whatever else is playing.
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
        if alarm == nil, let url = try? ToneFactory.alarmURL(), let p = try? AVAudioPlayer(contentsOf: url) {
            p.numberOfLoops = -1
            p.volume = 1.0
            p.prepareToPlay()
            alarm = p
        }
        alarm?.currentTime = 0
        alarm?.play()
        alarmActive = true
    }

    func stopAlarm() {
        alarm?.stop()
        alarmActive = false
        if keepaliveActive {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            keepalive?.play()
        }
    }

    func stopAll() {
        alarm?.stop()
        keepalive?.stop()
        alarmActive = false
        keepaliveActive = false
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    /// Short preview so the volume can be judged before a session.
    func previewAlarm(seconds: TimeInterval = 2) {
        playAlarm()
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self, !(self.keepaliveActive) else { return }
            self.stopAll()
        }
    }

    private func handleInterruption(_ n: Notification) {
        guard let raw = n.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .ended {
            resumeIfNeeded()
        }
    }

    func resumeIfNeeded() {
        guard keepaliveActive || alarmActive else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        if keepaliveActive, keepalive?.isPlaying == false { keepalive?.play() }
        if alarmActive, alarm?.isPlaying == false { alarm?.play() }
    }
}
