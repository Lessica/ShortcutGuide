//
//  WindowController.swift
//  ShortcutGuideExample
//
//  Created by Rachel on 2021/3/29.
//

import Cocoa
import ShortcutGuide

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        ShortcutGuideWindowController.registerShortcutGuideForWindow(window!)
    }
}

extension WindowController: ShortcutGuideDataSource {
    var shortcutItems: [ShortcutItem] {
        return []
    }
}
