//
//  WebViewController.swift
//  RanchForecastSplit
//
//  Created by Hanguang on 1/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {
    var webView: WKWebView {
        return view as! WKWebView
    }
    
    override func loadView() {
        let webView = WKWebView()
        view = webView
    }
    
    func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
}
