//
//  ShortcutItemView.swift
//  JSTColorPicker
//
//  Created by Darwin on 11/1/20.
//  Copyright © 2020 JST. All rights reserved.
//

import Cocoa

internal class ShortcutItemView: NSView {
    
    @IBOutlet weak var itemLabel:            NSTextField!
    @IBOutlet weak var itemKeyLabelControl:  NSTextField!
    @IBOutlet weak var itemKeyLabelOption:   NSTextField!
    @IBOutlet weak var itemKeyLabelShift:    NSTextField!
    @IBOutlet weak var itemKeyLabelCommand:  NSTextField!
    @IBOutlet weak var itemKeyLabelFunction: NSTextField!
    @IBOutlet weak var itemKeyLabel:         NSTextField!
    
    func updateDisplayWithItem(_ item: ShortcutItem) {
        itemLabel.stringValue = item.name
        itemKeyLabelControl.isHidden = !item.modifierFlags.contains(.control)
        itemKeyLabelOption.isHidden = !item.modifierFlags.contains(.option)
        itemKeyLabelShift.isHidden = !item.modifierFlags.contains(.shift)
        itemKeyLabelCommand.isHidden = !item.modifierFlags.contains(.command)
        itemKeyLabelFunction.isHidden = !item.modifierFlags.contains(.function)
        itemKeyLabel.stringValue = item.keyString
        itemLabel.toolTip = item.toolTip
    }
    
    func resetDisplay() {
        itemLabel.stringValue = ""
        itemKeyLabelControl.isHidden = true
        itemKeyLabelOption.isHidden = true
        itemKeyLabelShift.isHidden = true
        itemKeyLabelCommand.isHidden = true
        itemKeyLabelFunction.isHidden = true
        itemKeyLabel.stringValue = ""
    }
    
}
