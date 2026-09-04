import XCTest
@testable import LockdownCore

final class DepartureLogTests: XCTestCase {
    func testFileLogAppendUpdateReload() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = dir.appendingPathComponent("departures.json")
        let log = FileDepartureLog(url: url)
        var d = Departure(sessionId: UUID(), at: Date(timeIntervalSince1970: 1_800_000_000), kind: .pickup, durationSeconds: 12)
        try log.append(d)
        d.leftFor = "toilet"
        d.synced = true
        try log.update(d)

        let reloaded = try FileDepartureLog(url: url).all()
        XCTAssertEqual(reloaded, [d])
        try? FileManager.default.removeItem(at: dir)
    }

    func testPlaceholderText() {
        let d = Departure(sessionId: UUID(), at: Date(), kind: .pickup)
        XCTAssertEqual(d.leftForOrPlaceholder, "picked up the phone, reason not given")
        var e = d
        e.leftFor = "  "
        XCTAssertEqual(e.leftForOrPlaceholder, "picked up the phone, reason not given")
        e.leftFor = "water"
        XCTAssertEqual(e.leftForOrPlaceholder, "water")
    }
}
