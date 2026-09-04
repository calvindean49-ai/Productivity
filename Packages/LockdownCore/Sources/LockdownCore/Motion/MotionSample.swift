import Foundation

public struct Vector3: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var magnitude: Double { (x * x + y * y + z * z).squareRoot() }

    public static func - (a: Vector3, b: Vector3) -> Vector3 {
        Vector3(x: a.x - b.x, y: a.y - b.y, z: a.z - b.z)
    }
}

/// One CoreMotion device-motion reading, already split into gravity and user
/// acceleration (both in g). `t` is seconds on any monotonic clock.
public struct MotionSample: Codable, Equatable, Sendable {
    public var t: TimeInterval
    public var gravity: Vector3
    public var userAccel: Vector3

    public init(t: TimeInterval, gravity: Vector3, userAccel: Vector3) {
        self.t = t
        self.gravity = gravity
        self.userAccel = userAccel
    }
}
