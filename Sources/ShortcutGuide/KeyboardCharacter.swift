//
//  KeyboardCharacter.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/25.
//  Copyright © 2021 JST. All rights reserved.
//

import Foundation

extension ShortcutItem {
    public enum KeyboardCharacter: String, CaseIterable {
        case command = "⌘"
        case control = "⌃"
        case esc = "⎋"
        case option = "⌥"
        case shift = "⇧"
        case tab = "⇥"
        case space = "␣"
        case backspace = "⌫"
        case delete = "⌦"
        case enter = "⏎"
        case numberEnter = "⌤"
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
    }
}

public extension CharacterSet {
    static var keyboard: CharacterSet { CharacterSet(charactersIn: ShortcutItem.KeyboardCharacter.allCases.map({ $0.rawValue }).joined()) }
}
