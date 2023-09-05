# GlassGem

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Farmadsen%2FGlassGem%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/armadsen/GlassGem)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Farmadsen%2FGlassGem%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/armadsen/GlassGem)

---

GlassGem is a Swift package that implements the [Consistent Overhead Byte Stuffing (COBS)](https://en.wikipedia.org/wiki/Consistent_Overhead_Byte_Stuffing) algorithm for encoding arbitrary data with single byte packet delimiters.

It consists of an extension on `Data` with exactly two methods: `encodedUsingCOBS()` and `decodedFromCOBS()`. 

## Usage

Encoding:

```swift
let someData = ...
let cobsEncodedData = someData.encodedUsingCOBS()
// Do something with cobsEncodedData, e.g. sending across a communications link
``` 

Decoding:
```swift
let someCOBSEncodeData = ... // e.g. from a communications link
let someData = someData.decodedFromCOBS()
// Use someData like normal
``` 

The package includes a suite of unit tests.

## Installation

To use the `GlassGem` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/armadsen/GlassGem", from: "1.0.0"),
```

Include `"GlassGem"` as a dependency for your executable target:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "GlassGem", package: "GlassGem"),
]),
```

Finally, add `import GlassGem` to your source code.

## To Do

GlassGem is already completely usable for the most common scenarios. However, there are a few things I'd like to implement in the future. Pull requests for these are completely welcome. Please include tests for anything you add.

- [ ] Support for using GlassGem from Objective-C
- [ ] Support for arbitrary delimiter bytes, not just 0x00
- [ ] Performance improvements (while still emphasizing readability)
- [ ] Make documentation work with DocC
