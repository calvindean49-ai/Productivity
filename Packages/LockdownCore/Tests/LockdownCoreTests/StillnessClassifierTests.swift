import XCTest
@testable import LockdownCore

final class StillnessClassifierTests: XCTestCase {
    let config = LockdownConfig.default

    func sample(t: Double, gz: Double, ax: Double = 0, ay: Double = 0, az: Double = 0) -> MotionSample {
        MotionSample(t: t, gravity: Vector3(x: 0, y: 0, z: gz), userAccel: Vector3(x: ax, y: ay, z: az))
    }

    func testFaceDownStillIsAnchored() {
        var c = StillnessClassifier(config: config)
        var p = Posture(faceDown: false, still: false, gravityZ: 0, rms: 0, peak: 0, drift: 0)
        for i in 0..<40 {
            p = c.ingest(sample(t: Double(i) * 0.05, gz: 0.98, ax: 0.003))
        }
        XCTAssertTrue(p.faceDown)
        XCTAssertTrue(p.still)
        XCTAssertTrue(p.anchored)
    }

    func testFaceUpIsNotAnchoredEvenWhenStill() {
        var c = StillnessClassifier(config: config)
        var p = c.ingest(sample(t: 0, gz: -0.99))
        for i in 1..<40 { p = c.ingest(sample(t: Double(i) * 0.05, gz: -0.99)) }
        XCTAssertFalse(p.faceDown)
        XCTAssertTrue(p.still)
        XCTAssertFalse(p.anchored)
    }

    func testPickupBreaksStillness() {
        var c = StillnessClassifier(config: config)
        for i in 0..<40 { _ = c.ingest(sample(t: Double(i) * 0.05, gz: 0.98)) }
        // A hand lifts the phone: acceleration spike and gravity swings.
        let p = c.ingest(sample(t: 2.0, gz: 0.5, ax: 0.4, ay: 0.2))
        XCTAssertFalse(p.still, "peak acceleration above threshold")
        XCTAssertTrue(p.faceDown, "hysteresis keeps face-down until gravity drops below exit threshold")
        let p2 = c.ingest(sample(t: 2.05, gz: 0.3))
        XCTAssertFalse(p2.faceDown)
    }

    func testHysteresisBand() {
        var c = StillnessClassifier(config: config)
        var p = c.ingest(sample(t: 0, gz: 0.80))
        XCTAssertFalse(p.faceDown, "0.80 is below enter threshold 0.85")
        p = c.ingest(sample(t: 0.05, gz: 0.90))
        XCTAssertTrue(p.faceDown)
        p = c.ingest(sample(t: 0.10, gz: 0.75))
        XCTAssertTrue(p.faceDown, "0.75 is above exit threshold 0.70, still face down")
        p = c.ingest(sample(t: 0.15, gz: 0.65))
        XCTAssertFalse(p.faceDown)
    }

    func testSlowTiltIsCaughtByGravityDrift() {
        var c = StillnessClassifier(config: config)
        var p = c.ingest(sample(t: 0, gz: 0.98))
        // Gravity vector rotates slowly with almost no user acceleration.
        for i in 1...20 {
            let angle = Double(i) * 0.02
            let s = MotionSample(t: Double(i) * 0.05,
                                 gravity: Vector3(x: sin(angle), y: 0, z: cos(angle)),
                                 userAccel: Vector3(x: 0.001, y: 0, z: 0))
            p = c.ingest(s)
        }
        XCTAssertGreaterThan(p.drift, config.gravityDrift)
        XCTAssertFalse(p.still)
    }

    func testWindowForgetsOldMovement() {
        var c = StillnessClassifier(config: config)
        _ = c.ingest(sample(t: 0, gz: 0.98, ax: 0.5))
        var p = c.ingest(sample(t: 0.05, gz: 0.98))
        XCTAssertFalse(p.still)
        for i in 2..<60 { p = c.ingest(sample(t: Double(i) * 0.05, gz: 0.98)) }
        XCTAssertTrue(p.still, "spike older than the window no longer counts")
    }
}
