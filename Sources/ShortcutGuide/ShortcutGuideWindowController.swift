//
//  ShortcutGuideWindowController.swift
//  JSTColorPicker
//
//  Created by Darwin on 11/1/20.
//  Copyright © 2020 JST. All rights reserved.
//

import Cocoa

public enum ShortcutGuideColumnStyle {
    case single
    case dual
}

public class ShortcutGuideWindowController: NSWindowController {
    
    public static let shared = newShortcutGuideController()

    public var animationBehavior: NSWindow.AnimationBehavior? {
        get { window?.animationBehavior }
        set { window?.animationBehavior = newValue ?? .default }
    }
    
    private static func newShortcutGuideController() -> ShortcutGuideWindowController {
        let windowStoryboard = NSStoryboard(name: "ShortcutGuide", bundle: Bundle.module)
        let sgWindowController = windowStoryboard.instantiateInitialController() as! ShortcutGuideWindowController
        return sgWindowController
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        window?.level = .statusBar
        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.animationBehavior = .default
    }
    
    private var localMonitor: Any?
    private var globalMonitor: Any?
    
    deinit {
        // Clean up click recognizer
        removeCloseOnOutsideClick()
    }
    
    /**
     Creates a monitor for outside clicks. If clicking outside of this view or
     any views in `ignoringViews`, the view will be hidden.
     */
    private func addCloseOnOutsideClick(ignoring ignoringViews: [NSView]? = nil) {
        guard let window = window, let contentView = window.contentView else { return }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown], handler: { [weak self] (event) -> NSEvent? in
            guard window.isVisible else { return event }
            var shouldHide = false
            if window != event.window {
                // Click other windows
                shouldHide = true
            } else {
                let localLoc = contentView.convert(event.locationInWindow, from: nil)
                if !contentView.bounds.contains(localLoc) {
                    // If the click is in any of the specified views to ignore, don't hide
                    for ignoreView in ignoringViews ?? [NSView]() {
                        let frameInWindow: NSRect = ignoreView.convert(ignoreView.bounds, to: nil)
                        if frameInWindow.contains(event.locationInWindow) {
                            // Abort if clicking in an ignored view
                            return event
                        }
                    }
                    // Getting here means the click should hide the view
                    shouldHide = true
                }
            }
            if shouldHide {
                // Perform your hiding code here
                self?.hide()
            }
            return event
            
        })
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] (event) -> Void in
            guard window.isVisible else { return }
            self?.hide()
        }
    }
    
    private func removeCloseOnOutsideClick() {
        if localMonitor != nil {
            NSEvent.removeMonitor(localMonitor!)
            localMonitor = nil
        }
        if globalMonitor != nil {
            NSEvent.removeMonitor(globalMonitor!)
            globalMonitor = nil
        }
    }


    // MARK: - Registered Window Events

    public var preferredColumnStyle: ShortcutGuideColumnStyle = .dual
    private var managedWindows = [ManagedWindow]()

    public static func registerShortcutGuideForWindow(_ extWindow: NSWindow) {
        ShortcutGuideWindowController.shared.registerShortcutGuideForWindow(extWindow)
    }

    private func registerShortcutGuideForWindow(_ extWindow: NSWindow) {
        guard let eventMonitor = (NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] (event) -> NSEvent? in
            guard let self = self, event.window == extWindow else { return event }
            if self.monitorWindowFlagsChanged(with: event) {
                return nil
            }
            return event
        }) else {
            fatalError("fail to add local monitor")
        }
        let closingSubscription = NotificationCenter.default.observe(name: NSWindow.willCloseNotification, object: extWindow, eventMonitors: [eventMonitor]) { [weak self] notification in
            guard let window = notification.object as? NSWindow else { return }
            self?.managedWindows.removeAll(where: { $0.window == window })
        }
        managedWindows.append(
            ManagedWindow(
                window: extWindow,
                closingSubscription: closingSubscription
            )
        )
    }

    private var lastCommandPressedAt: TimeInterval = 0.0
    private func commandPressed(with event: NSEvent?) -> Bool {
        guard let eventWindow = event?.window else { return false }
        let now = event?.timestamp ?? Date().timeIntervalSinceReferenceDate
        if now - lastCommandPressedAt < 0.4 {
            ShortcutGuideWindowController.shared
                .loadItemsForWindow(eventWindow)
            ShortcutGuideWindowController.shared
                .toggleForWindow(eventWindow, columnStyle: preferredColumnStyle)
            lastCommandPressedAt = 0.0
            return true
        } else {
            lastCommandPressedAt = now
        }
        return false
    }

    private func commandCancelled() -> Bool {
        lastCommandPressedAt = 0.0
        return false
    }

    @discardableResult
    private func monitorWindowFlagsChanged(with event: NSEvent?, forceReset: Bool = false) -> Bool {
        guard let eventWindow = event?.window, eventWindow.isKeyWindow else { return false }
        var handled = false
        let modifierFlags = (event?.modifierFlags ?? NSEvent.modifierFlags)
            .intersection(.deviceIndependentFlagsMask)
        if modifierFlags.isEmpty
        {
            handled = false
        }
        else
        {
            if modifierFlags.contains(.command) &&
                modifierFlags.subtracting(.command).isEmpty
            {
                handled = commandPressed(with: event)
            } else {
                handled = commandCancelled()
            }
        }
        return handled
    }
    
    
    // MARK: - Toggle
    
    public var isVisible: Bool { window?.isVisible ?? false }

    private static func inspectItemsForWindow(_ extWindow: NSWindow) -> [ShortcutItem] {
        var items = [ShortcutItem]()
        var responder: NSResponder? = extWindow.firstResponder
        while responder != nil {
            if let thisResponder = responder as? ShortcutGuideDataSource {
                items.append(contentsOf: thisResponder.shortcutItems)
            }
            responder = responder?.nextResponder
        }
        return items
    }

    public func loadItemsForWindow(_ extWindow: NSWindow) {
        items = ShortcutGuideWindowController.inspectItemsForWindow(extWindow)
    }
    
    public func showForWindow(_ extWindow: NSWindow, columnStyle style: ShortcutGuideColumnStyle?) {
        prepareForPresentation(window: extWindow, columnStyle: style ?? preferredColumnStyle)
        showWindow(nil)
        addCloseOnOutsideClick()
    }
    
    public func hide() {
        removeCloseOnOutsideClick()
        window?.orderOut(nil)
    }
    
    public func toggleForWindow(_ extWindow: NSWindow, columnStyle style: ShortcutGuideColumnStyle?) {
        guard let window = window else { return }
        if !window.isVisible {
            showForWindow(extWindow, columnStyle: style)
        } else {
            hide()
        }
    }
    
    
    // MARK: - Shortcut Items

    public var items: [ShortcutItem]? {
        get {
            rootViewController.items
        }
        set {
            rootViewController.items = newValue
        }
    }

    private var rootViewController: ShortcutGuidePageController {
        contentViewController as! ShortcutGuidePageController
    }

    private func prepareForPresentation(window: NSWindow, columnStyle style: ShortcutGuideColumnStyle) {
        rootViewController.prepareForPresentation(window: window, columnStyle: style)
    }
    
}

extension ShortcutGuideWindowController: NSWindowDelegate {
    
    public func windowDidResignKey(_ notification: Notification) {
        self.hide()
    }
    
}
