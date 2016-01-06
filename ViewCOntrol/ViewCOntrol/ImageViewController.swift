//
//  ImageViewController.swift
//  ViewCOntrol
//
//  Created by Hanguang on 1/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa

class ImageViewController: NSViewController, ImageRepresentable {

    var image: NSImage?
    override var nibName: String? {
        return "ImageViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
