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
    
    private static func newShortcutGuideController() -> ShortcutGuideWindowController {
        let windowStoryboard = NSStoryboard(name: "ShortcutGuide", bundle: Bundle.module)
        let sgWindowController = windowStoryboard.instantiateInitialController() as! ShortcutGuideWindowController
        return sgWindowController
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        window?.level = .statusBar
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
            
            let localLoc = contentView.convert(event.locationInWindow, from: nil)
            if !contentView.bounds.contains(localLoc) && window.isVisible == true {
                
                // If the click is in any of the specified views to ignore, don't hide
                for ignoreView in ignoringViews ?? [NSView]() {
                    let frameInWindow: NSRect = ignoreView.convert(ignoreView.bounds, to: nil)
                    if frameInWindow.contains(event.locationInWindow) {
                        // Abort if clicking in an ignored view
                        return event
                    }
                }
                
                // Getting here means the click should hide the view
                // Perform your hiding code here
                self?.hide()
                
            }
            
            return event
            
        })
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] (event) -> Void in
            if window.isVisible == true {
                self?.hide()
            }
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


    // MARK: - Events

    public var preferredColumnStyle: ShortcutGuideColumnStyle = .dual

    public static func registerShortcutGuideForWindow(_ extWindow: NSWindow) {
        ShortcutGuideWindowController.shared.registerShortcutGuideForWindow(extWindow)
    }

    private func registerShortcutGuideForWindow(_ extWindow: NSWindow) {
        attachedWindow = extWindow

        NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] (event) -> NSEvent? in
            guard let self = self else { return event }
            if self.monitorWindowFlagsChanged(with: event) {
                return nil
            }
            return event
        }
    }

    private var lastCommandPressedAt: TimeInterval = 0.0
    private func commandPressed(with event: NSEvent?) -> Bool {
        guard let attachedWindow = attachedWindow else { return false }  // important
        let now = event?.timestamp ?? Date().timeIntervalSinceReferenceDate
        if now - lastCommandPressedAt < 0.6 {
            var items = [ShortcutItem]()
            var responder: NSResponder? = attachedWindow.firstResponder
            while responder != nil {
                if let thisResponder = responder as? ShortcutGuideDataSource {
                    items.append(contentsOf: thisResponder.shortcutItems)
                }
                responder = responder?.nextResponder
            }
            ShortcutGuideWindowController.shared.items = items
            ShortcutGuideWindowController.shared
                .toggleForWindow(attachedWindow, columnStyle: preferredColumnStyle)
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
        guard let attachedWindow = attachedWindow, attachedWindow.isKeyWindow else { return false }  // important
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
    public private(set) var attachedWindow: NSWindow? {
        get {
            rootViewController.attachedWindow
        }
        set {
            rootViewController.attachedWindow = newValue
        }
    }
    
    public func showForWindow(_ extWindow: NSWindow?, columnStyle style: ShortcutGuideColumnStyle?) {
        attachedWindow = extWindow
        prepareForPresentation(columnStyle: style ?? preferredColumnStyle)
        showWindow(nil)
        addCloseOnOutsideClick()
    }
    
    public func hide() {
        removeCloseOnOutsideClick()
        window?.orderOut(nil)
    }
    
    public func toggleForWindow(_ extWindow: NSWindow?, columnStyle style: ShortcutGuideColumnStyle?) {
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

    private func prepareForPresentation(columnStyle style: ShortcutGuideColumnStyle) {
        rootViewController.prepareForPresentation(columnStyle: style)
    }
    
}

extension ShortcutGuideWindowController: NSWindowDelegate {
    
    public func windowDidResignKey(_ notification: Notification) {
        self.hide()
    }
    
}
