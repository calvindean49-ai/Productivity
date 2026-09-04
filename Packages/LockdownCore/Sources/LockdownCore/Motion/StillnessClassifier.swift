import Foundation

/// What the classifier believes about the phone right now.
public struct Posture: Equatable, Sendable {
    public var faceDown: Bool
    public var still: Bool
    /// Both at once: the phone is where a session wants it.
    public var anchored: Bool { faceDown && still }

    // Diagnostics for the Calibration screen.
    public var gravityZ: Double
    public var rms: Double
    public var peak: Double
    public var drift: Double

    public init(faceDown: Bool, still: Bool, gravityZ: Double, rms: Double, peak: Double, drift: Double) {
        self.faceDown = faceDown
        self.still = still
        self.gravityZ = gravityZ
        self.rms = rms
        self.peak = peak
        self.drift = drift
    }
}

/// Face-down detection with hysteresis plus a sliding-window stillness test.
///
/// CoreMotion's gravity vector in the device frame reads about z = -1 when the
/// phone lies face up on a table and about z = +1 face down. Stillness is
/// judged over the last `windowSeconds` of samples: rms and peak of user
/// acceleration, and how far the gravity vector drifted across the window
/// (a slow tilt shows up there before it shows up in acceleration).
public struct StillnessClassifier: Sendable {
    public private(set) var config: LockdownConfig
    private var window: [MotionSample] = []
    private var faceDown = false

    public init(config: LockdownConfig) {
        self.config = config
    }

    public mutating func update(config: LockdownConfig) {
        self.config = config
    }

    public mutating func reset() {
        window.removeAll()
        faceDown = false
    }

    public mutating func ingest(_ sample: MotionSample) -> Posture {
        window.append(sample)
        let cutoff = sample.t - config.windowSeconds
        while let first = window.first, first.t < cutoff {
            window.removeFirst()
        }

        // Hysteresis on the face-down flag.
        let gz = sample.gravity.z
        if faceDown {
            if gz < config.faceDownExit { faceDown = false }
        } else if gz > config.faceDownEnter {
            faceDown = true
        }

        var sumSq = 0.0
        var peak = 0.0
        for s in window {
            let m = s.userAccel.magnitude
            sumSq += m * m
            if m > peak { peak = m }
        }
        let rms = (sumSq / Double(window.count)).squareRoot()
        let drift = window.first.map { (sample.gravity - $0.gravity).magnitude } ?? 0

        let still = rms < config.stillRMS && peak < config.stillPeak && drift < config.gravityDrift
        return Posture(faceDown: faceDown, still: still, gravityZ: gz, rms: rms, peak: peak, drift: drift)
    }
}
