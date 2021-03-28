//
//  ShortcutGuidePageController.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/25.
//  Copyright © 2021 JST. All rights reserved.
//

import Cocoa

internal class ShortcutGuidePageController: NSPageController, NSPageControllerDelegate {

    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var pageControl: ShortcutGuidePageControl!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var items: [ShortcutItem]?
    var groups: [ShortcutItemGroup]? { arrangedObjects as? [ShortcutItemGroup] }
    func group(with identifier: String) -> ShortcutItemGroup? {
        guard let groups = groups else {
            return nil
        }
        return groups.first(where: { $0.identifier == identifier })
    }

    private var pageConstraints: [NSLayoutConstraint]?
    private var columnStyle: ShortcutGuideColumnStyle = .dual
    private var isSinglePage: Bool { arrangedObjects.count <= 1 }

    func prepareForPresentation(columnStyle style: ShortcutGuideColumnStyle) {
        columnStyle = style
        if let items = items, items.count > 0 {
            let maximumCount = style == .dual ? 16 : 8
            arrangedObjects = ShortcutItemGroup.splitItemsIntoGroups(items, maximumCount: maximumCount)
        } else {
            arrangedObjects = [ ShortcutItemGroup.empty ]
        }
        selectedIndex = 0
        pageControl.numberOfPages = arrangedObjects.count
        pageControl.currentPage = 0
        view.needsUpdateConstraints = true
    }

    private func maskImage(cornerRadius: CGFloat) -> NSImage {
        let edgeLength = 2.0 * cornerRadius + 1.0
        let maskImage = NSImage(size: NSSize(width: edgeLength, height: edgeLength), flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.black.set()
            bezierPath.fill()
            return true
        }
        maskImage.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage.resizingMode = .stretch
        return maskImage
    }

    weak var attachedWindow: NSWindow?

    private func centerInScreenForWindow(_ parent: NSWindow?) {
        if let window = view.window, let screen = parent?.screen ?? window.screen {
            let xPos = screen.frame.minX + screen.frame.width / 2.0 - window.frame.width / 2.0
            let yPos = screen.frame.minY + screen.frame.height / 2.0 - window.frame.height / 2.0
            window.setFrame(NSRect(x: xPos, y: yPos, width: window.frame.width, height: window.frame.height), display: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self

        visualEffectView.blendingMode = .behindWindow
        if #available(OSX 10.14, *) {
            visualEffectView.material = .hudWindow
        } else {
            visualEffectView.material = .appearanceBased
            // Fallback on earlier versions
        }
        visualEffectView.state = .active
        visualEffectView.maskImage = maskImage(cornerRadius: 16.0)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        view.window?.contentView = visualEffectView
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        transitionStyle = .horizontalStrip
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        centerInScreenForWindow(attachedWindow)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        centerInScreenForWindow(attachedWindow)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        if let superview = view.superview {
            if let pageConstraints = pageConstraints {
                NSLayoutConstraint.deactivate(pageConstraints)
                self.pageConstraints = nil
            }
            let constraints = [
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
            pageConstraints = constraints
        }
        if !isSinglePage && columnStyle == .single {
            widthConstraint.priority = .defaultHigh
            heightConstraint.priority = .defaultHigh
        } else {
            widthConstraint.priority = .defaultLow
            heightConstraint.priority = .defaultLow
        }
    }

    func pageController(_ pageController: NSPageController, prepare viewController: NSViewController, with object: Any?) {
        guard object != nil, let ctrl = viewController as? ShortcutGuideViewController else { return }
        ctrl.updateDisplayWithItems((object as! ShortcutItemGroup).items)
        ctrl.isSinglePage = isSinglePage
        ctrl.view.needsUpdateConstraints = true
    }

    func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        return self.storyboard!.instantiateController(withIdentifier: "ShortcutGuideViewController") as! ShortcutGuideViewController
    }

    func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        return (object as! ShortcutItemGroup).identifier!
    }

    func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
        completeTransition()
        pageControl.currentPage = selectedIndex
    }

    override func cursorUpdate(with event: NSEvent) {
        super.cursorUpdate(with: event)
        NSCursor.arrow.set()
    }

}
