# BearLibTerminal-Swift

Swifty bindings for [BearLibTerminal](http://foo.wyrd.name/en:bearlibterminal).

This repo is compatible with the Swift package manager. It has not yet been tested
with Carthage or Cocoapods.

```swift
let terminal = BLTerminal.main
terminal.open()
terminal.print(point: BLPoint(x: 0, y: 0), string: "[color=red]Hi![/color]")
terminal.waitForExit()
terminal.close()
```

## Setup

You need to add a new dependency to your `Package.swift`:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "My Game",
    dependencies: [
         .package(url: "https://github.com/irskep/BearLibTerminal-Swift.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "My Game",
            dependencies: ["BearLibTerminal"]),

    ]
)
```

You **also** need to link against the BearLibTerminal shared library! On OS X,
that's `libBearLibTerminal.dylib` ([download](http://foo.wyrd.name/_media/en:bearlibterminal:bearlibterminal_0.15.7_osx.zip)).
See [the BearLibTerminal site](http://foo.wyrd.name/en:bearlibterminal) for more links.

## Why it's better than using the C bridge directly

The C library plays fast and loose with signedness of ints. You need to convert an `Int8`
to a `UInt8` pretty regularly, and it can be hard to remember where and how to do this.

Also, If you code against the interface, you can write tests for your code without showing
a GUI.

## Docs

If you're reading this from GitHub, please [visit the full documentation.](http://steveasleep.com/BearLibTerminal-Swift)

If you would like more documentation, please open a GitHub issue so
I know someone cares!
