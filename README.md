# ShortcutGuide

Double-click command to present a shortcut guide for your macOS application.

## Usage

Add these lines to your root window's `NSWindowController`:

```swift
import ShortcutGuide
// ...
override func windowDidLoad() {
    super.windowDidLoad()
    // ...
    ShortcutGuideWindowController.registerShortcutGuideForWindow(window!)
}
```

Then, make some parts of your responder chain (`NSView` or `NSViewController`) conform to `ShortcutGuideDataSource`:

```swift
public protocol ShortcutGuideDataSource: NSResponder {
    var shortcutItems: [ShortcutItem] { get }
}
```

Define and provide your shortcuts from the protocol method above:

```swift
public struct ShortcutItem {
    let name: String
    let keyString: String
    let toolTip: String
    let modifierFlags: NSEvent.ModifierFlags
}
```

## License

Copyright © 2021 Zheng Wu. All rights reserved.
