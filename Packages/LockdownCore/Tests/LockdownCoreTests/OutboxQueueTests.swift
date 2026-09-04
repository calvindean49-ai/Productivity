import XCTest
@testable import LockdownCore

final class OutboxQueueTests: XCTestCase {
    let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    func testBackoffGrowsAndCaps() {
        XCTAssertEqual(OutboxQueue.backoff(afterAttempts: 1), 30)
        XCTAssertEqual(OutboxQueue.backoff(afterAttempts: 2), 60)
        XCTAssertEqual(OutboxQueue.backoff(afterAttempts: 3), 120)
        XCTAssertEqual(OutboxQueue.backoff(afterAttempts: 20), 3600)
    }

    func testEnqueueDueSucceedFail() {
        let q = OutboxQueue(storage: InMemoryOutboxStorage())
        let a = q.enqueue(.departure(departureId: UUID(), leftFor: "water", app: nil), at: t0)
        let b = q.enqueue(.stopSitting(durationMinutes: 50), at: t0.addingTimeInterval(1))
        XCTAssertEqual(q.due(at: t0).map(\.id), [a.id])
        XCTAssertEqual(q.due(at: t0.addingTimeInterval(1)).map(\.id), [a.id, b.id])

        q.failed(a.id, at: t0.addingTimeInterval(2))
        XCTAssertEqual(q.due(at: t0.addingTimeInterval(2)).map(\.id), [b.id])
        // Both due again; order is by creation time, not by retry time.
        XCTAssertEqual(q.due(at: t0.addingTimeInterval(2 + 30)).map(\.id), [a.id, b.id])

        q.succeeded(b.id)
        XCTAssertEqual(q.items.map(\.id), [a.id])
        XCTAssertEqual(q.items[0].attempts, 1)
    }

    func testFilePersistenceRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = dir.appendingPathComponent("outbox.json")
        let q1 = OutboxQueue(storage: FileOutboxStorage(url: url))
        let item = q1.enqueue(.departure(departureId: UUID(), leftFor: "tea", app: "Safari"), at: t0)

        let q2 = OutboxQueue(storage: FileOutboxStorage(url: url))
        XCTAssertEqual(q2.items, [item])
        try? FileManager.default.removeItem(at: dir)
    }
}
