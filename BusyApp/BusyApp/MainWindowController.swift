//
//  MainWindowController.swift
//  BusyApp
//
//  Created by Hanguang on 9/23/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var verticalSlider: NSSlider!
    @IBOutlet weak var sliderLabel: NSTextField!
    @IBOutlet weak var resetControlButton: NSButton!
    @IBOutlet weak var uncheckButton: NSButton!
    @IBOutlet weak var secureTextField: NSSecureTextField!
    @IBOutlet weak var revealSecureTextButton: NSButton!
    @IBOutlet weak var revealTextField: NSTextField!
    @IBOutlet weak var showTickButton: NSButton!
    @IBOutlet weak var hideTickButton: NSButton!
    
    var numberOfTickMars: Int {
        return Int(verticalSlider.maxValue / 10)
    }
    
    var lastSliderValue: Double!
    
    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        resetValue()
    }
    
    func resetValue() {
        verticalSlider.doubleValue = 0.0
        lastSliderValue = verticalSlider.doubleValue
        showSliderTickMark(hideTickButton)
        uncheckButton.state = NSOnState
        checkTouched(uncheckButton)
        secureTextField.stringValue = ""
        revealTextField.stringValue = ""
        revealTextField.editable = false
    }
    
    @IBAction func sliderValueChanged(sender: NSSlider) {
        print("Slider value: \(sender.doubleValue)")
        let value = sender.doubleValue
        if (value > lastSliderValue) {
            sliderLabel.stringValue = "Slider goes up!"
        } else if (value == lastSliderValue) {
            sliderLabel.stringValue = "Slider staying the same!"
        } else if (value < lastSliderValue) {
            sliderLabel.stringValue = "Slider goes down!"
        }
        lastSliderValue = value
    }
    
    @IBAction func resetControlsTouched(sender: NSButton) {
        resetValue()
    }
    
    @IBAction func showSliderTickMark(sender: NSButton) {
        if (sender.tag == 0) {
            hideTickButton.state = NSOffState
            verticalSlider.numberOfTickMarks = numberOfTickMars
            verticalSlider.allowsTickMarkValuesOnly = true
        } else {
            showTickButton.state = NSOffState
            verticalSlider.numberOfTickMarks = 0
        }
        sender.state = NSOnState
    }
    
    @IBAction func checkTouched(sender: NSButton) {
        let state = sender.state
        if (state == NSOnState) {
            sender.title = "Uncheck me"
        } else {
            sender.title = "Check me"
        }
    }
    
    @IBAction func revealSecretMessage(sender: NSButton) {
        revealTextField.stringValue = secureTextField.stringValue
    }
    
}
