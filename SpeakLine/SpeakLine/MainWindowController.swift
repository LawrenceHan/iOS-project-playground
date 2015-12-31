//
//  MainWindowController.swift
//  SpeakLine
//
//  Created by Hanguang on 9/24/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSSpeechSynthesizerDelegate, NSWindowDelegate,
NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var speakButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let preferenceManager = PreferenceManager()
    let speechSynth = NSSpeechSynthesizer()
    
    let voices = NSSpeechSynthesizer.availableVoices()
    
    var isStarted: Bool = false {
        didSet {
            updateButtons()
        }
    }
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        updateButtons()
        speechSynth.delegate = self
        for voice in voices {
            print(voiceNameForIdentifier(voice)!)
        }
        let defaultVoice = preferenceManager.activeVoice!
        if let defaultRow = voices.indexOf(defaultVoice) {
            let indices = NSIndexSet(index: defaultRow)
            tableView.selectRowIndexes(indices, byExtendingSelection: false)
            tableView.scrollRowToVisible(defaultRow)
        }
        textField.stringValue = preferenceManager.activeText!
    }
    
    // MARK: - Action methods
    
    @IBAction func speakIt(sender: NSButton) {
        // Get typed-in text as a string
        let string = textField.stringValue
        if string.isEmpty {
            print("string from \(textField) is empty")
        } else {
            speechSynth.startSpeakingString(textField.stringValue)
            isStarted = true
        }
    }
    
    @IBAction func stopIt(sender: NSButton) {
        speechSynth.stopSpeaking()
    }
    
    @IBAction func resetPreferences(sender: AnyObject) {
        preferenceManager.resetPreference()
        let activeVoice = preferenceManager.activeVoice!
        let row = voices.indexOf(activeVoice)!
        let indices = NSIndexSet(index: row)
        tableView.selectRowIndexes(indices, byExtendingSelection: false)
        textField.stringValue = preferenceManager.activeText!
    }
    
    func updateButtons() {
        if isStarted {
            speakButton.enabled = false
            stopButton.enabled = true
        } else {
            speakButton.enabled = true
            stopButton.enabled = false
        }
    }
    
    func updateTextField() {
        if speechSynth.speaking {
            textField.enabled = false
        } else {
            textField.enabled = true
        }
    }
    
    
    func speechSynthesizer(sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        isStarted = false
        updateTextField()
        print("finishedSpeaking=\(finishedSpeaking)")
    }
    
    func speechSynthesizer(sender: NSSpeechSynthesizer,
        willSpeakWord characterRange: NSRange,
        ofString string: String) {
            let range = characterRange
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttributes([NSForegroundColorAttributeName: NSColor.greenColor()], range: range)
            textField.attributedStringValue = attributedString
            updateTextField()
    }
    
    func voiceNameForIdentifier(identifier: String) -> String? {
        let attributes = NSSpeechSynthesizer.attributesForVoice(identifier)
        return attributes[NSVoiceName] as? String
    }
    
    // MARK: - NSWindowDelegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return !isStarted
    }
    
//    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
//        return NSSizeFromCGSize(CGSizeMake(frameSize.height * 2, frameSize.height))
//    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return voices.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let voice = voices[row]
        let voiceName = voiceNameForIdentifier(voice)
        return voiceName
    }
    
    // MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(notification: NSNotification) {
        let row = tableView.selectedRow
        
        // Set the voice back to the default if the user has deseleted all rows
        if row == -1 {
            speechSynth.setVoice(nil)
            return
        }
        let voice = voices[row]
        speechSynth.setVoice(voice)
        preferenceManager.activeVoice = voice
    }
    
    // MARK: - NSTextFieldDelegate
    override func controlTextDidChange(obj: NSNotification) {
        preferenceManager.activeText = textField.stringValue
    }
}
