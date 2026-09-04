import Foundation

/// Generates the two sounds the app needs as WAV files in Caches, so the repo
/// carries no binary assets and nothing needs afconvert.
enum ToneFactory {
    static let sampleRate = 44_100

    static func silenceURL() throws -> URL {
        try file(named: "keepalive.wav") {
            [Int16](repeating: 0, count: sampleRate) // 1 s of digital silence
        }
    }

    /// Two seconds of alternating 2.2 kHz / 3.1 kHz bursts. Harsh on
    /// purpose: it has to be heard through a desk and a jumper.
    static func alarmURL() throws -> URL {
        try file(named: "alarm.wav") {
            var out: [Int16] = []
            out.reserveCapacity(sampleRate * 2)
            let pattern: [(freq: Double, on: Bool)] = [
                (2200, true), (0, false), (3100, true), (0, false), (2200, true), (3100, true), (0, false),
            ]
            let burst = Int(Double(sampleRate) * 0.14)
            let gap = Int(Double(sampleRate) * 0.06)
            for step in pattern {
                let n = step.on ? burst : gap
                for i in 0..<n {
                    if step.on {
                        let t = Double(i) / Double(sampleRate)
                        // Square-ish wave (clipped sine) for more energy per sample.
                        let s = sin(2 * .pi * step.freq * t) * 3
                        let clipped = max(-1, min(1, s))
                        out.append(Int16(clipped * 32_000))
                    } else {
                        out.append(0)
                    }
                }
            }
            // Pad to exactly 2 s so the loop is even.
            let target = sampleRate * 2
            if out.count < target { out += [Int16](repeating: 0, count: target - out.count) }
            return Array(out.prefix(target))
        }
    }

    private static func file(named name: String, samples: () -> [Int16]) throws -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = dir.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path) { return url }
        try wavData(samples()).write(to: url, options: .atomic)
        return url
    }

    /// 16-bit mono PCM.
    static func wavData(_ samples: [Int16]) -> Data {
        var d = Data()
        let dataSize = UInt32(samples.count * 2)
        func put<T: FixedWidthInteger>(_ v: T) {
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { d.append(contentsOf: $0) }
        }
        d.append(contentsOf: Array("RIFF".utf8))
        put(UInt32(36 + dataSize))
        d.append(contentsOf: Array("WAVE".utf8))
        d.append(contentsOf: Array("fmt ".utf8))
        put(UInt32(16))          // chunk size
        put(UInt16(1))           // PCM
        put(UInt16(1))           // channels
        put(UInt32(sampleRate))
        put(UInt32(sampleRate * 2)) // byte rate
        put(UInt16(2))           // block align
        put(UInt16(16))          // bits per sample
        d.append(contentsOf: Array("data".utf8))
        put(dataSize)
        for s in samples { put(s) }
        return d
    }
}
