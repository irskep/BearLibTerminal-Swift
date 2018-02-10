//
//  BearLibTerminal.swift
//  BearLibTerminal-Swift
//
//  Created by Steve Johnson on 1/5/18.
//  Copyright © 2018 Steve Johnson. All rights reserved.
//

import Foundation
import CBearLibTerminal


/// Int type used by BearLibTerminal
public typealias BLInt = Int32

/// Opaque color type used by BearLibTerminal
public typealias BLColor = UInt32


/**
 Simple rectangle struct to simplify the API. (BearLibTerminal-Swift uses
 this instead of CGRect to avoid a Core Graphics dependency, making Linux
 support possible.)
 */
public struct BLRect: Equatable, Codable {
    public var x: BLInt
    public var y: BLInt
    public var w: BLInt
    public var h: BLInt
    public static func ==(_ a: BLRect, _ b: BLRect) -> Bool { return a.x == b.x && a.y == b.y && a.w == b.w && a.h == b.h }
    public init(x: BLInt, y: BLInt, w: BLInt, h: BLInt) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
    }
}

/**
 Simple point struct to simplify the API. (BearLibTerminal-Swift uses
 this instead of CGPoint to avoid a Core Graphics dependency, making Linux
 support possible.)
 */
public struct BLPoint: Equatable, Codable {
    public var x: BLInt
    public var y: BLInt
    public static var zero = BLPoint(x: 0, y: 0)
    public static func ==(_ a: BLPoint, _ b: BLPoint) -> Bool { return a.x == b.x && a.y == b.y }
    public init(x: BLInt, y: BLInt) {
        self.x = x
        self.y = y
    }
}
extension BLPoint: Hashable {
    public var hashValue: Int {
        return x.hashValue &* 31 &+ y.hashValue
    }
}

/**
 Simple size struct to simplify the API. (BearLibTerminal-Swift uses
 this instead of CGSize to avoid a Core Graphics dependency, making Linux
 support possible.)
 */
public struct BLSize: Equatable, Codable {
    public var w: BLInt
    public var h: BLInt
    public static func ==(_ a: BLSize, _ b: BLSize) -> Bool { return a.w == b.w && a.h == b.h }
    public init(w: BLInt, h: BLInt) {
        self.w = w
        self.h = h
    }
}


/**
 API for talking to BearLibTerminal. See `BLTerminal` for the concrete
 implementation. Use `BLTerminal.main` to get the main instance.

 Each docstring briefly explains how it relates to the C API, so you'll
 probably want to refer to
 [the original documentation](http://foo.wyrd.name/en:bearlibterminal:reference)
 for more information.

 By writing your code against this protocol instead of the concrete
 `BLTerminal` type, you enable unit testing and possible cross-platform
 compatibility adapters in the future.
 */
public protocol BLTerminalInterface: class {
    /// `terminal_open()`
    func open()

    /// `terminal_close()`
    func close()

    /// `terminal_set()`
    @discardableResult func configure(_ config: String) -> Bool

    /// `terminal_refresh()`
    func refresh()

    /// `terminal_clear()`
    func clear()

    /// `terminal_clear_area()`
    func clear(area: BLRect)

    /// `terminal_crop()`
    func crop(area: BLRect)

    /// `terminal_delay()`
    func delay(milliseconds: BLInt)

    /// `terminal_measure()`
    func measure(string: String) -> BLSize

    /// `terminal_print()`
    @discardableResult func print(point: BLPoint, string: String) -> BLSize

    /// `terminal_put()`
    func put(point: BLPoint, code: BLInt)

    /// `terminal_put_ext()`
    func put(point: BLPoint, code: BLInt, offset: BLPoint, nw: BLColor, sw: BLColor, se: BLColor, ne: BLColor)

    /// `color_from_name()`
    func getColor(name: String) -> BLColor

    /// `color_from_argb()`
    func getColor(a: UInt8, r: UInt8, g: UInt8, b: UInt8) -> BLColor

    /// `terminal_pick()`
    func pickCode(point: BLPoint, index: BLInt) -> BLInt

    /// `terminal_pick_color()`
    func pickForegroundColor(point: BLPoint, index: BLInt) -> BLColor

    /// `terminal_pick_bkcolor()`
    func pickBackgroundColor(point: BLPoint, index: BLInt) -> BLColor

    /// `terminal_peek()`
    func peek() -> Int32

    /// `terminal_read()`
    func read() -> Int32

    /// `terminal_state()`
    func state(_ slot: Int32) -> Int32

    /// `terminal_check()`
    func check(_ slot: Int32) -> Bool

    /// `terminal_read_str()`
    func readString(point: BLPoint, max: BLInt) -> String?

    /// `terminal_has_input()`
    var hasInput: Bool { get }

    /// `terminal_layer()` / `terminal_state(TK_LAYER)`
    var layer: BLInt { get set }

    /// `terminal_color()` / `terminal_state(TK_COLOR)`
    var foregroundColor: BLColor { get set }

    /// `terminal_layer()` / `terminal_state(TK_LAYER)`
    var backgroundColor: BLColor { get set }

    /// `terminal_composition()` / `terminal_state(TK_COMPOSITION)`
    var isCompositionEnabled: Bool { get set }
}

public extension BLTerminalInterface {
    /// Block until the user quits. This isn't part of the original
    /// BearLibTerminal library, but it's convenient for quick experiments.
    public func waitForExit() {
        while self.read() != BLConstant.CLOSE { }
        self.close()
    }
}

/**
 Concrete implementation of `BLTerminalInterface`. Refer to that protocol
 for method details.

 Use `BLTerminal.main` to get a terminal object instance.
 */
public class BLTerminal: BLTerminalInterface {
    /// Main instance of `BLTerminal`. There isn't any point in creating
    /// more than one instance unless you're writing tests, since all the
    /// methods just call BearLibTerminal's global-state functions.
    public static var main: BLTerminalInterface = { BLTerminal() }()

    public init() { }

    public func open() { terminal_open() }

    public func close() { terminal_close() }

    @discardableResult
    public func configure(_ config: String) -> Bool {
        let s = Array(config.utf8CString)
        return terminal_set(UnsafePointer(s)) != 0
    }

    public func refresh() { terminal_refresh() }

    public func clear() { terminal_clear() }

    public func check(_ slot: Int32) -> Bool { return terminal_check(slot) != 0 }

    public func state(_ slot: Int32) -> Int32 { return terminal_state(slot) }

    public func clear(area: BLRect) {
        terminal_clear_area(area.x, area.y, area.w, area.h)
    }

    public func crop(area: BLRect) {
        terminal_crop(area.x, area.y, area.w, area.h)
    }

    public func delay(milliseconds: BLInt) {
        terminal_delay(milliseconds)
    }

    public func measure(string: String) -> BLSize {
        let s = Array(string.utf8CString)
        let result: dimensions_t = terminal_measure(UnsafePointer(s))
        return BLSize(w: result.width, h: result.height)
    }

    @discardableResult
    public func print(point: BLPoint, string: String) -> BLSize {
        let s = Array(string.utf8CString)
        let result = terminal_print(point.x, point.y, UnsafePointer(s))
        return BLSize(w: result.width, h: result.height)
    }

    public func put(point: BLPoint, code: BLInt) {
        terminal_put(point.x, point.y, code)
    }

    public func put(point: BLPoint, code: BLInt, offset: BLPoint, nw: BLColor, sw: BLColor, se: BLColor, ne: BLColor) {
        let cornersArray: [color_t] = [nw, sw, se, ne]
        let ptr = UnsafeMutablePointer(mutating: cornersArray)
        terminal_put_ext(point.x, point.y, offset.x, offset.y, code, ptr)
    }

    public func getColor(name: String) -> BLColor {
        let s = Array(name.utf8CString)
        return color_from_name(UnsafePointer(s))
    }

    public func getColor(a: UInt8, r: UInt8, g: UInt8, b: UInt8) -> BLColor {
        return color_from_argb(a, r, g, b)
    }

    public func pickCode(point: BLPoint, index: BLInt) -> BLInt {
        return terminal_pick(point.x, point.y, index)
    }

    public func pickForegroundColor(point: BLPoint, index: BLInt) -> BLColor {
        return terminal_pick_color(point.x, point.y, index)
    }

    public func pickBackgroundColor(point: BLPoint, index: BLInt) -> BLColor {
        return terminal_pick_bkcolor(point.x, point.y)
    }

    public func peek() -> Int32 {
        return terminal_peek()
    }

    public func read() -> Int32 {
        return terminal_read()
    }

    public func readString(point: BLPoint, max: BLInt) -> String? {
        var bytes = [Int8](repeating: 0, count: Int(max))
        let result = terminal_read_str(point.x, point.y, &bytes, max)
        if result <= 0 {
            return nil
        }
        let data: Data = Data(bytes: bytes.map({ UInt8(bitPattern: $0) }))
        if let longString = String(data: data, encoding: .utf8) {
            return String(longString.prefix(Int(result)))
        } else {
            return nil
        }
    }

    public var hasInput: Bool {
        return terminal_has_input() != 0
    }

    public var layer: BLInt {
        get { return terminal_state(TK_LAYER) }
        set { terminal_layer(newValue) }
    }

    public var foregroundColor: BLColor {
        get { return BLColor(bitPattern: terminal_state(TK_COLOR)) }
        set { terminal_color(newValue) }
    }

    public var backgroundColor: BLColor {
        get { return BLColor(bitPattern: terminal_state(TK_BKCOLOR)) }
        set { terminal_bkcolor(newValue) }
    }

    public var isCompositionEnabled: Bool {
        get { return terminal_state(BLConstant.COMPOSITION) == BLConstant.ON }
        set { terminal_composition(newValue ? BLConstant.ON : BLConstant.OFF) }
    }
}
