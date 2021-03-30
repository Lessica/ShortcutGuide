//
//  KeyboardCharacter.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/25.
//  Copyright © 2021 JST. All rights reserved.
//

import Cocoa

extension ShortcutItem {
    public enum KeyboardCharacter: String, CaseIterable {
        case command = "⌘"
        case control = "⌃"
        case esc = "⎋"
        case option = "⌥"
        case shift = "⇧"
        case tab = "⇥"
        case space = "␣"
        case delete = "⌫"
        case deleteForward = "⌦"
        case `return` = "⏎"
        case numericEnter = "⌤"
        case capsLock = "⇪"
        case clear = "⌧"
        case home = "⤒"
        case end = "⤓"
        case pageUp = "↑"
        case pageDown = "↓"
        case up = "▲"
        case down = "▼"
        case left = "◀"
        case right = "▶"
        case eject = "⏏"

        static let function = "fn"
        static let backspace = KeyboardCharacter.delete
        static let enter = KeyboardCharacter.return
    }
}

public extension CharacterSet {
    static var keyboard: CharacterSet { CharacterSet(charactersIn: ShortcutItem.KeyboardCharacter.allCases.map({ $0.rawValue }).joined()) }
}
