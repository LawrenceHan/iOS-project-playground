//
//  EmployeesPrintingView.swift
//  RaiseMan
//
//  Created by Hanguang on 1/1/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa

private let font: NSFont = NSFont.userFixedPitchFontOfSize(12.0)!
private let textAttributes: [String : AnyObject] = [NSFontAttributeName : font]
private let lineHeight: CGFloat = font.capHeight * 2.0

class EmployeesPrintingView: NSView {
    
    let employees: [Employee]

    var pageRect = NSRect()
    var linesPerPage: Int = 0
    var currentPage: Int = 0
    
    // MARK: - Lifecycle
    init(employees: [Employee]) {
        self.employees = employees
        super.init(frame: NSRect())
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Pagination
    override func knowsPageRange(range: NSRangePointer) -> Bool {
        let printOperation = NSPrintOperation.currentOperation()!
        let printInfo: NSPrintInfo = printOperation.printInfo
        
        // Where can I draw?
        pageRect = printInfo.imageablePageBounds
        let newFrame = NSRect(origin: CGPoint(), size: printInfo.paperSize)
        frame = newFrame
        
        // How many lines per page?
        linesPerPage = Int(pageRect.height / lineHeight)
        
        // Construct the range to return
        var rangeOut = NSRange(location: 0, length: 0)
        
        // Pages are 1-based. That is, the first page is page 1.
        rangeOut.location = 1
        
        // How many pages will it take
        rangeOut.length = employees.count / linesPerPage
        if employees.count % linesPerPage > 0 {
            rangeOut.length += 1
        }
        
        // Return the newly constructed range, rangeOut, via the range pointer
        range.memory = rangeOut
        
        return true
    }
    
    override func rectForPage(page: Int) -> NSRect {
        // Note the current page
        // Although Cocoa uses 1-based indexing for the page number
        // it's easier not to do that here
        currentPage = page - 1
        
        // Return the same page rect every time
        return pageRect
    }
    
    // MARK: - Drawing
    
    // The origin of the view is at the upper-left corner
    override var flipped: Bool {
        return true
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        var nameRect = NSRect(x: pageRect.minX, y: 0, width: 200, height: lineHeight)
        var raiseRect = NSRect(x: nameRect.maxX, y: 0, width: 100, height: lineHeight)
        
        for indexOnPage in 0..<linesPerPage {
            let indexInEmployees = currentPage * linesPerPage + indexOnPage
            if indexInEmployees >= employees.count {
                break
            }
            
            let employee = employees[indexInEmployees]
            
            // Draw index and name
            nameRect.origin.y = pageRect.minY + CGFloat(indexOnPage) * lineHeight
            let employeeName = (employee.name ?? "")
            let indexAndName = "\(indexInEmployees) \(employeeName)"
            indexAndName.drawInRect(nameRect, withAttributes: textAttributes)
            
            // Draw raise
            raiseRect.origin.y = nameRect.minY
            let raise = String(format: "%4.1f%%", employee.raise * 100)
            let raiseString = raise
            raiseString.drawInRect(raiseRect, withAttributes: textAttributes)
        }
        
        let pageString = String(format: "Page: %i", currentPage)
        let pageStringRect = NSRect(x: raiseRect.maxX, y: raiseRect.origin.y, width: 100, height: lineHeight)
        pageString.drawInRect(pageStringRect, withAttributes: textAttributes)
    }
    
}
