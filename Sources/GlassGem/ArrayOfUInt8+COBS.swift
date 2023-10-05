//
//  ArrayOfUInt8+Cobs.swift
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

/// This extension provides methods for encoding and decoding data using the Consistent Overhead Byte Stuffing (COBS)
/// algorithm. COBS is way to packetize data for transmission over possibly error-prone communication links. It is very efficient/lower overhead
/// using the zero (0x00) byte as a packet delimiter, and replacing zeros in the actual data being sent with minimal replacement data.
/// For more information, see https://en.wikipedia.org/wiki/Consistent_Overhead_Byte_Stuffing. This implementation
/// prioritizes readibility over performance, as it is used (by the author) for very small amounts of data.
public extension Array where Element == UInt8 {


    /// Encode the receiver using the COBS algorithm. The result will always end in a zero (0x00) byte, which is the packet
    /// delimiter under standard COBS.
    /// - Returns: A new Data object containing the receiver's data encoded using COBS.
    func encodedUsingCOBS() -> [UInt8] {
        // Here we're using the 'Prefixed block description' encoding algorithm
        var scratch = self

        // 1. Append a zero byte
        scratch += [0]

        var groups = [[UInt8]]()
        var currentGroup = [UInt8]()
        var currentCount: UInt8 = 0

        // 2. Break into groups of either 254 non-zero bytes or 0-253 non-zero bytes followed by a zero byte
        for byte in scratch {
            currentGroup.append(byte)
            // If we see a zero byte, or we're up to 253 non-zero bytes, we've finished a group
            if byte == 0 || currentCount >= 253 {
                groups.append(currentGroup)
                currentGroup = [UInt8]()
                currentCount = 0
            } else { // Otherwise, just keep building the current group
                currentCount += 1
            }
        }

        // 3. Prepend the number of non-zero bytes plus one to each group
        groups = groups.map { group in
            var scratch = group
            if scratch[scratch.endIndex.advanced(by: -1)] == 0x00 {
                scratch.removeLast()
            }
            scratch.insert(UInt8(scratch.count+1), at: 0)
            return scratch
        }

        // 4. Concatenate all encoded groups
        var result = [UInt8](groups.flatMap { $0 })
        // 5. Append a final trailing zero, which is the packet delimiter
        result.append(0)

        return result
    }

    /// Decode the receiver using the COBS algorithm. Calling this on data that is not COBS encoded will
    /// produce surprising results.
    /// - Returns: An array of individual [UInt8] objects each representing a packet in the original COBS encoded receiver. Note that the packet delimiter zero bytes will be removed from each packet.
    func decodedFromCOBS() -> [[UInt8]] {
        // 1. Split the data into invidual packets, which are separated by zero bytes
        let rawPackets = self.split(separator: 0)
        var result = [[UInt8]]()
        result.reserveCapacity(rawPackets.count)

        // 2. Loop through each packet
        for var packet in rawPackets {
            var groupHeaderIndexesToRemove = [[UInt8].Index]()

            // 3. The first byte is always the index of the first zero byte
            var nextZeroOffset = Int(packet[packet.startIndex])
            var nextZeroAddress = packet.startIndex.advanced(by: nextZeroOffset)
            // 4. Continue walking to each zero byte location as indicated by the value of the
            // last zero byte location
            while true {
                // If we're at the end of the packet, finish up
                if nextZeroAddress >= packet.endIndex {
                    break
                }
                // 5. Replace each zero byte offset with the original zero value
                // But only if it's a group header (ie. we're at the end of a full non-zero group)
                if nextZeroOffset < 255 {
                    // The offest to the next zero byte is the value here
                    nextZeroOffset = Int(packet[nextZeroAddress])
                    packet[nextZeroAddress] = 0
                } else {
                    // The offest to the next zero byte is the value here
                    nextZeroOffset = Int(packet[nextZeroAddress])
                    // Otherwise just remove it, because it's a group header
                    groupHeaderIndexesToRemove.append(nextZeroAddress)
                }
                // Get the address of the next zero byte using the offset and current location
                nextZeroAddress = nextZeroAddress.advanced(by: nextZeroOffset)
            }

            // 6. Remove all group header addresses
            for index in groupHeaderIndexesToRemove.reversed() {
                packet.remove(at: index)
            }

            // 7. Remove the first byte which is never part of the original (see step 3 in encoding algorithm)
            packet.removeFirst()
            result.append(Array(packet))
        }

        return result
    }
}
