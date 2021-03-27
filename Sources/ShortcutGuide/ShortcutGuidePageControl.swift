//
//  ShortcutGuidePageControl.swift
//  JSTColorPicker
//
//  Created by Rachel on 2021/3/25.
//  Copyright © 2021 JST. All rights reserved.
//

import Cocoa

internal class ShortcutGuidePageControl: NSView {

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

    var pageIndicatorTintColor: NSColor = NSColor(white: 1.0, alpha: 0.5) {
        didSet {
            needsDisplay = true
        }
    }

    var currentPageIndicatorTintColor: NSColor = NSColor.white {
        didSet {
            needsDisplay = true
        }
    }

    var hidesForSinglePage: Bool = true {
        didSet {
            needsDisplay = true
        }
    }

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

        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        for idx in 0..<numberOfPages {
            let indexOffset: CGFloat    = (dotWidth + dotPadding) * CGFloat(idx)
            let x: CGFloat              = minX + indexOffset
            let rect: CGRect            = NSRect(x: x, y: minY, width: dotWidth, height: dotWidth)

            ctx.addEllipse(in: rect)
            ctx.setFillColor((idx == currentPage ? currentPageIndicatorTintColor : pageIndicatorTintColor).cgColor)
            ctx.fillPath()
        }
    }
}
