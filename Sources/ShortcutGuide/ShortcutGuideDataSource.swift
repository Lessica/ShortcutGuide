//
//  ShortcutGuideDataSource.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/27.
//  Copyright © 2021 JST. All rights reserved.
//

import Cocoa

public protocol ShortcutGuideDataSource: NSResponder {
    var shortcutItems: [ShortcutItem] { get }
}
