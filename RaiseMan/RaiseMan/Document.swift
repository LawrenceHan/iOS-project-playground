//
//  Document.swift
//  RaiseMan
//
//  Created by Hanguang on 9/28/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class Document: NSDocument, NSWindowDelegate {

    private var KVOContext: Int = 0
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var arrayController: NSArrayController!
    
    var employees: [Employee] = [] {
        willSet {
            for employee in employees {
                stopObservingEmployee(employee)
            }
        }
        didSet {
            for employee in employees {
                startObservingEmployee(employee)
            }
        }
    }
    
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
    
    // MARK: - Actions
    @IBAction func addEmployee(sender: NSButton) {
        let windowController = windowControllers[0]
        let window = windowController.window!
        
        let endedEditing = window.makeFirstResponder(window)
        if !endedEditing {
            print("Unable to end editing.")
            return
        }
        
        let undo: NSUndoManager = undoManager!
        
        // Has an edit occurred already in this event?
        if undo.groupingLevel > 0 {
            // Close the last group
            undo.endUndoGrouping()
            // Open a new group
            undo.beginUndoGrouping()
        }
        
        // Create the object
        let employee = arrayController.newObject() as! Employee
        
        // Add it to the array controller's contentArray
        arrayController.addObject(employee)
        
        // Re-sort (in case the user has sorted a column)
        arrayController.rearrangeObjects()
        
        // Get the sorted array
        let sortedEmployees = arrayController.arrangedObjects as! [Employee]
        
        // Find the object just added
        let row = sortedEmployees.indexOf(employee)!
        
        // Begin the edit in the first column
        print("starting edit of \(employee) in row \(row)")
        tableView.editColumn(0, row: row, withEvent: nil, select: true)
    }

    @IBAction func removeEmployees(sender: NSButton) {
        let selectedPeople: [Employee] = arrayController.selectedObjects as! [Employee]
        let alert = NSAlert()
        
        alert.addButtonWithTitle("Remove")
        alert.addButtonWithTitle("Cancel")
        
        if selectedPeople.count > 1 {
            alert.informativeText = "\(selectedPeople.count) people will be removed."
            alert.messageText = "Do you really want to remove these people?"
            alert.addButtonWithTitle("Keep, but no raise")
        } else {
            alert.informativeText = "\(selectedPeople.first!.name!) will be removed."
            alert.messageText = "Do you really want to remove this person?"
        }
        
        let window = sender.window!
        alert.beginSheetModalForWindow(window) { (response) -> Void in
            // If the user chose "Remove", tell the array controller to delete the people
            switch response {
            case NSAlertFirstButtonReturn:
                // The array controller will delete the selected objects
                // The argument to remove() is ignored
                self.arrayController.remove(nil)
            case NSAlertThirdButtonReturn:
                // clear all selected employee raise to zero
                for (_, employee) in selectedPeople.enumerate() {
                    employee.raise = 0.0
                }
                self.arrayController.rearrangeObjects()
            default:break
            }
        }
    }
    
    // MARK: - Accessors
    func insertObject(employee: Employee, inEmployeesAtIndex index: Int) {
        print("adding \(employee) to the employees array")
        
        // Add the inverse of this opeartion to the undo stack
        let undo: NSUndoManager = undoManager!
        undo.prepareWithInvocationTarget(self).removeObjectFromEmployeesAtIndex(employees.count)
        if !undo.undoing {
            undo.setActionName("Add Person")
        }
        
        employees.append(employee)
    }
    
    func removeObjectFromEmployeesAtIndex(index: Int) {
        let employee: Employee = employees[index]
        
        print("removing \(employee) from the employees array")
        
        // Add the inverse of this opeartion to the undo stack
        let undo: NSUndoManager = undoManager!
        undo.prepareWithInvocationTarget(self).insertObject(employee, inEmployeesAtIndex: index)
        if !undo.undoing {
            undo.setActionName("Remove Person")
        }
        
        // Remove the Employee from the array
        employees.removeAtIndex(index)
    }
    
    // MARK: - Key Value Observing
    func startObservingEmployee(employee: Employee) {
        employee.addObserver(self, forKeyPath: "name", options: .Old, context: &KVOContext)
        employee.addObserver(self, forKeyPath: "raise", options: .Old, context: &KVOContext)
    }
    
    func stopObservingEmployee(employee: Employee) {
        employee.removeObserver(self, forKeyPath: "name")
        employee.removeObserver(self, forKeyPath: "raise")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if let keyPath = keyPath, object = object, change = change {
                if context != &KVOContext {
                    // If the context does not match, this message must be intended for our superclass
                    super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
                    return
                }
                
                var oldValue: AnyObject? = change[NSKeyValueChangeOldKey]
                if oldValue is NSNull {
                    oldValue = nil
                }
                
                let undo: NSUndoManager = undoManager!
                print("oldValue = \(oldValue)")
                undo.prepareWithInvocationTarget(object).setValue(oldValue, forKeyPath: keyPath)
            }
            
    }
    
    
    // MARK: - NSWindowDelegate
    func windowWillClose(notification: NSNotification) {
        employees = []
    }
    
    override func dataOfType(typeName: String) throws -> NSData {
        // End editing
        tableView.window!.endEditingFor(nil)
        
        // Create an NSData object from the employees array
        return NSKeyedArchiver.archivedDataWithRootObject(employees)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        employees = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Employee]
    }

    

}

