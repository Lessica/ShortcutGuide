//
//  ShortcutGuidePageControl.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/25.
//  Copyright © 2021 JST. All rights reserved.
//

import Cocoa

internal class ShortcutGuidePageControl: NSControl {

    var numberOfPages: Int = 0 {
        didSet {
            needsDisplay = true
        }
    }

    var currentPage: Int = 0 {
        didSet {
            needsDisplay = true
        }
    }

    var dotWidth: CGFloat = 7.0 {
        didSet {
            needsDisplay = true
        }
    }

    var dotPadding: CGFloat = 7.0 {
        didSet {
            needsDisplay = true
        }
    }

    var pageIndicatorTintColor: NSColor = NSColor.labelColor.withAlphaComponent(0.5) {
        didSet {
            needsDisplay = true
        }
    }

    var currentPageIndicatorTintColor: NSColor = NSColor.labelColor {
        didSet {
            needsDisplay = true
        }
    }

    var hidesForSinglePage: Bool = true {
        didSet {
            needsDisplay = true
        }
    }

    private var dotRects: [CGRect]?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if hidesForSinglePage && numberOfPages == 1 {
            return
        }

        let dotWidthSum          = dotWidth * CGFloat(numberOfPages)
        let marginWidthSum       = dotPadding * CGFloat((numberOfPages - 1))
        let minimumRequiredWidth = dotWidthSum + marginWidthSum
        let minX                 = (bounds.width - minimumRequiredWidth) / 2
        let verticalCenter       = (bounds.height - dotWidth) / 2
        let minY                 = verticalCenter - dotWidth / 2
        let hasEnoughHeight      = bounds.height >= dotWidth
        let hasEnoughWidth       = bounds.width >= minimumRequiredWidth

        if !hasEnoughWidth || !hasEnoughHeight {
            debugPrint("bounds doesn't have enough space to draw all dots")
            debugPrint("current rect : \(dirtyRect)")
            debugPrint("required size: \(CGSize(width: minimumRequiredWidth, height: dotWidth))")
            return
        }

        var rects = [CGRect]()
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        for idx in 0..<numberOfPages {
            let indexOffset: CGFloat    = (dotWidth + dotPadding) * CGFloat(idx)
            let x: CGFloat              = minX + indexOffset
            let rect: CGRect            = NSRect(x: x, y: minY, width: dotWidth, height: dotWidth)

            rects.append(rect)
            ctx.addEllipse(in: rect)
            ctx.setFillColor((idx == currentPage ? currentPageIndicatorTintColor : pageIndicatorTintColor).cgColor)
            ctx.fillPath()
        }
        dotRects = rects
    }

    override func mouseUp(with event: NSEvent) {
        if let dotRects = dotRects {
            let locInView = convert(event.locationInWindow, from: nil)
            if let clickedDotIndex = dotRects.firstIndex(where: { $0.contains(locInView) }) {
                currentPage = clickedDotIndex

                if let action = action {
                    NSApp.sendAction(action, to: self.target, from: self)
                }
                needsDisplay = true
            }
        }
    }

}
