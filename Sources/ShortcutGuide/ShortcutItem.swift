//
//  ShortcutItem.swift
//  JSTColorPicker
//
//  Created by Darwin on 11/1/20.
//  Copyright © 2020 JST. All rights reserved.
//

import Cocoa

public struct ShortcutItem {
    public init(name: String, keyString: String, toolTip: String, modifierFlags: NSEvent.ModifierFlags) {
        self.name = name
        self.keyString = keyString
        self.toolTip = toolTip
        self.modifierFlags = modifierFlags
    }

    public init(name: String, keyString: ShortcutItem.KeyboardCharacter, toolTip: String, modifierFlags: NSEvent.ModifierFlags) {
        self.name = name
        self.keyString = keyString.rawValue
        self.toolTip = toolTip
        self.modifierFlags = modifierFlags
    }

    public let name: String
    public let keyString: String
    public let toolTip: String
    public let modifierFlags: NSEvent.ModifierFlags
}
