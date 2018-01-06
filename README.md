# BearLibTerminal-Swift

Swifty bindings for [BearLibTerminal](http://foo.wyrd.name/en:bearlibterminal).

This repo is compatible with the Swift package manager.

```swift
let terminal = RKTerminal.main
terminal.open()
terminal.print(point: RKPoint(x: 0, y: 0), string: "[color=red]Hi![/color]")
terminal.waitForExit()
terminal.close()
```

The code is very short. Please read `Sources/BearLibTerminal` to get a sense
of the interface and data types.

If you would like more documentation, please open a GitHub issue so
I know someone cares!