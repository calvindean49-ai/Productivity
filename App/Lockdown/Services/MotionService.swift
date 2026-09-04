import CoreMotion
import Foundation
import LockdownCore

/// CMDeviceMotion in, `MotionSample` out. Has no opinion about posture.
///
/// Known iOS quirk: on some hardware updates stop when the app goes to the
/// background even under the audio background mode; the fix is to stop and
/// restart updates on `didEnterBackground`, which `restart()` exists for.
final class MotionService {
    private let manager = CMMotionManager()
    private var handler: (@MainActor (MotionSample) -> Void)?
    private(set) var hz: Double = 20

    var isAvailable: Bool { manager.isDeviceMotionAvailable }
    var isRunning: Bool { manager.isDeviceMotionActive }

    func start(hz: Double = 20, handler: @escaping @MainActor (MotionSample) -> Void) {
        self.hz = hz
        self.handler = handler
        begin()
    }

    func restart() {
        guard handler != nil else { return }
        manager.stopDeviceMotionUpdates()
        begin()
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        handler = nil
    }

    private func begin() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / hz
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let m = motion else { return }
            let sample = MotionSample(
                t: m.timestamp,
                gravity: Vector3(x: m.gravity.x, y: m.gravity.y, z: m.gravity.z),
                userAccel: Vector3(x: m.userAcceleration.x, y: m.userAcceleration.y, z: m.userAcceleration.z)
            )
            // The callback queue is `.main`, so this is already on the main actor.
            MainActor.assumeIsolated { self.handler?(sample) }
        }
    }
}
