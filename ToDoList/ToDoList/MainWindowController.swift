//
//  MainWindowController.swift
//  ToDoList
//
//  Created by Hanguang on 9/25/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate,
NSTextFieldDelegate {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var toDoItems = [String]()
    
    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        addButton.enabled = !textField.stringValue.isEmpty
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func addItem(sender: NSButton) {
        let itemName = textField.stringValue
        textField.stringValue = ""
        createNewItemWithName(itemName)
    }
    
    func createNewItemWithName(string: String) {
        toDoItems.append(string)
        tableView.reloadData()
    }
    
    // MARK: Tableview Delegate
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return toDoItems.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let item = toDoItems[row]
        return item
    }
    
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
    
    // MARK: Textfield Delegate
    override func controlTextDidChange(obj: NSNotification) {
        addButton.enabled = !textField.stringValue.isEmpty
    }
}
