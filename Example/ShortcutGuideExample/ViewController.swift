//
//  ViewController.swift
//  ShortcutGuideExample
//
//  Created by Rachel on 2021/3/29.
//

import Cocoa
import ShortcutGuide

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

extension ViewController: ShortcutGuideDataSource {
    private func randomModifierFlags() -> NSEvent.ModifierFlags {
        let maxCnt = Int.random(in: 1...5)
        let closures: [(NSEvent.ModifierFlags) -> NSEvent.ModifierFlags] = [
            { input in
                return input.union(.control)
            },
            { input in
                return input.union(.command)
            },
            { input in
                return input.union(.option)
            },
            { input in
                return input.union(.shift)
            },
            { input in
                return input.union(.function)
            },
        ]
        var masks: NSEvent.ModifierFlags = []
        for _ in 0..<maxCnt {
            masks = closures[Int.random(in: 0..<closures.count)](masks)
        }
        return masks
    }

    var shortcutItems: [ShortcutItem] {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" + ShortcutItem.KeyboardCharacter.allCases.map({ $0.rawValue }).joined()
        let itemClosures: [() -> ShortcutItem] = [
            { [unowned self] in
                return ShortcutItem(name: "Short Item", keyString: String(characters.randomElement()!), toolTip: "", modifierFlags: self.randomModifierFlags())
            },
            { [unowned self] in
                return ShortcutItem(name: "Medium Item Medium Item", keyString: String(characters.randomElement()!), toolTip: "", modifierFlags: self.randomModifierFlags())
            },
            { [unowned self] in
                return ShortcutItem(name: "Long Item Long Item Long Item Long Item", keyString: String(characters.randomElement()!), toolTip: "", modifierFlags: self.randomModifierFlags())
            },
            {
                return ShortcutItem(name: "Custom Item", keyString: "Whatever you want", toolTip: "Whatever you want", modifierFlags: [])
            }
        ]
        var items = [ShortcutItem]()
        for _ in 0..<Int.random(in: 0...48) {
            items.append(itemClosures.randomElement()!())
        }
        return items
    }
}

