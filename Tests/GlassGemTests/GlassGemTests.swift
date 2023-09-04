//
//  GlassGemTests.swift
//
//  Created by Andrew R Madsen on 9/2/23.
//
//  MIT License
//
//  Copyright (c) 2023 Andrew R. Madsen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import XCTest
@testable import GlassGem

final class GlassGemTests: XCTestCase {

    let baseTestTable: [[UInt8] : [UInt8]] = [
        [0x01] : [0x02, 0x01, 0x00],
        [0x00] : [0x01, 0x01, 0x00],
        [0x00, 0x00] : [0x01, 0x01, 0x01, 0x00],
        [0x00, 0x11, 0x00] : [0x01, 0x02, 0x11, 0x01, 0x00],
        [0x11, 0x22, 0x00, 0x33] : [0x03, 0x11, 0x22, 0x02, 0x33, 0x00],
        [0x11, 0x22, 0x33, 0x44] : [0x05, 0x11, 0x22, 0x33, 0x44, 0x00],
        [0x11, 0x00, 0x00, 0x00] : [0x02, 0x11, 0x01, 0x01, 0x01, 0x00],
    ]

    func testEncoding() {
        for (original, encoded) in baseTestTable {
            let encodedOriginal = Data(original).encodedUsingCOBS()
            XCTAssertEqual(encodedOriginal, Data(encoded), "Encoding failed for \(original)). Expected \(encoded). Got \([UInt8](encodedOriginal)).")
        }
    }

    func testDecoding() {
        for (original, encoded) in baseTestTable {
            let decodedResults = Data(encoded).decodedFromCOBS()
            XCTAssertEqual(decodedResults.count, 1)
            let decodedResult = decodedResults[0]
            XCTAssertEqual(decodedResult, Data(original), "Decoding failed for \(encoded)). Expected \(original). Got \([UInt8](decodedResult)).")
        }
    }

    func testRoundTrip() {
        for original in baseTestTable.keys {
            let encoded = Data(original).encodedUsingCOBS()
            let decoded = encoded.decodedFromCOBS()[0]
            XCTAssertEqual(Data(original), decoded, "Round trip encode/decode failed for \(original)). Expected \(original). Got \([UInt8](decoded)).")
        }
    }

    func testDecodingMultiplePacketsInOneData() {
        let allOriginals = baseTestTable.keys.map { Data($0) }
        let allEncoded = allOriginals.map { $0.encodedUsingCOBS() }
        let multiplePackets = Data(allEncoded.joined())
        let decoded = multiplePackets.decodedFromCOBS()
        XCTAssertEqual(allOriginals, decoded)
    }

    func testPacketSizesNearGroupBoundaries() {
        for i in 1...10 {
            let original = Data.random(byteCount: i * 254)
            let encoded = original.encodedUsingCOBS()
            let decoded = encoded.decodedFromCOBS()[0]
            XCTAssertEqual(original, decoded, "Round trip encode/decode failed for random \([UInt8](original)). Expected \([UInt8](original)). Got \([UInt8](decoded)).")
        }
    }

    func testLongZeroRuns() {
        for i in 1...10 {
            let basePacket = Data.random(byteCount: 50)
            let zeros = Data(repeating: 0, count: i*50)
            let original = basePacket + zeros + basePacket
            let encoded = original.encodedUsingCOBS()
            let decoded = encoded.decodedFromCOBS()[0]
            XCTAssertEqual(original, decoded, "Round trip encode/decode failed for random \([UInt8](original)). Expected \([UInt8](original)). Got \([UInt8](decoded)).")
        }
    }

    func testLongNonZeroRuns() {
        for i in 1...10 {
            let basePacket = Data.random(byteCount: 50)
            let nonZero = Data.random(byteCount: i*50, allowZero: false)
            let original = basePacket + nonZero + basePacket
            let encoded = original.encodedUsingCOBS()
            let decoded = encoded.decodedFromCOBS()[0]
            XCTAssertEqual(original, decoded, "Round trip encode/decode failed for random \([UInt8](original)). Expected \([UInt8](original)). Got \([UInt8](decoded)).")
        }
    }

    func testLargeRandomPackets() {
        for _ in 0..<1000 {
            let original = Data.random(byteCount: Int.random(in: 0...10000))
            let encoded = original.encodedUsingCOBS()
            let decoded = encoded.decodedFromCOBS()[0]
            XCTAssertEqual(original, decoded, "Round trip encode/decode failed for random \([UInt8](original)). Expected \([UInt8](original)). Got \([UInt8](decoded)).")
        }
    }
}

private extension Data {
    static func random(byteCount: Int, allowZero: Bool = true) -> Data {
        var result = Data(capacity: byteCount)
        let range: ClosedRange<UInt8> = allowZero ? 0...255 : 1...255
        for _ in 0..<byteCount {
            result.append(UInt8.random(in: range))
        }
        return result
    }
}
