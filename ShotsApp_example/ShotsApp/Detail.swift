//
//  Detail.swift
//  ShotsApp
//
//  Created by Meng To on 2014-07-29.
//  Copyright (c) 2014 Meng To. All rights reserved.
//

import UIKit

class Detail: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    var data = Array<Dictionary<String,String>>()
    var number = 0
    
    @IBAction func backButtonDidPress(sender: AnyObject) {
        performSegueWithIdentifier("detailToHome", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "detailToHome" {
            let controller = segue.destinationViewController as! Home
            controller.data = data
            controller.number = number
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authorLabel.text = data[number]["author"]
        avatarImageView.image = UIImage(named: data[number]["avatar"]!)
        imageView.image = UIImage(named: data[number]["image"]!)
        descriptionTextView.text = data[number]["text"]
        
        backButton.alpha = 0
        
        textViewWithFont(descriptionTextView, fontName: "Libertad", fontSize: 16, lineSpacing: 7)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        backButton.alpha = 1
        springScaleFrom(backButton!, x: -100, y: 0, scaleX: 0.5, scaleY: 0.5)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
