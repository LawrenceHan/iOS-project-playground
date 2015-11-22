//
//  Document.swift
//  RaiseManCoreData
//
//  Created by Hanguang on 11/22/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class Document: NSPersistentDocument {

    @IBOutlet var arrayController: EmployeeArrayController!
    @IBOutlet weak var tableView: NSTableView!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }
    
    @IBAction func addEmployee(sender: NSButton) {
        // Create a new employee
        let employee = arrayController.newObject() as! NSManagedObject
        // Add it to array controller
        arrayController.addObject(employee)
        // Sort the array in case it needed
        arrayController.rearrangeObjects()
        
        let sortedEmployees = arrayController.arrangedObjects as! [NSManagedObject]
        let row = sortedEmployees.indexOf(employee)!
        tableView.editColumn(0, row: row, withEvent: nil, select: true)
    }
    

}
