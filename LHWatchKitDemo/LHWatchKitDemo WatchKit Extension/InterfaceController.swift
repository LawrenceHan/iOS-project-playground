//
//  InterfaceController.swift
//  LHWatchKitDemo WatchKit Extension
//
//  Created by Hanguang on 4/29/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet weak var guessSlider: WKInterfaceSlider!
    @IBOutlet weak var guessLabel: WKInterfaceLabel!
    @IBOutlet weak var resultLabel: WKInterfaceLabel!
    
    var guessNumber = 3
    
    // MARK: View life cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: Button method

    @IBAction func updateGuess(value: Float) {
        guessNumber = Int(value * 5)
        guessLabel.setText("Your guess: \(guessNumber)")
    }
    @IBAction func startGuess() {
        var randomNumber = Int(arc4random_uniform(6))
        if (guessNumber == randomNumber) {
            resultLabel.setText("Correct. You win!")
        } else {
            resultLabel.setText("Wrong. The number is \(randomNumber)")
        }
    }
    
}
