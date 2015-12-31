//
//  TiledImageView.swift
//  ImageTiling
//
//  Created by Hanguang on 12/13/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

@IBDesignable class TiledImageView: NSView {

    @IBInspectable var image: NSImage?
    let columnCount = 5
    let rowCount = 5
    
    override func drawRect(dirtyRect: NSRect) {
        if let image = image {
            for x in 0..<columnCount {
                for y in 0..<rowCount {
                    let frame = frameForImageAtLogicalX(x, y)
                    image.drawInRect(frame)
                }
            }
        }
    }
    
    override var intrinsicContentSize: NSSize {
        let furthestFrame = frameForImageAtLogicalX(columnCount-1, rowCount-1)
        return NSSize(width: furthestFrame.maxX, height: furthestFrame.maxY)
    }
    
    // MARK: - Drawing
    func frameForImageAtLogicalX(logicalX: Int, _ logicalY: Int) -> CGRect {
        let spacing = 10
        let width = 100
        let height = 100
        let x = (spacing + width) * logicalX
        let y = (spacing + height) * logicalY
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
