//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit

class NotificationsViewController: BaseElloViewController {

    @IBOutlet var containerView : UIView! = nil
    var webView: WKWebView!

//    override func loadView() {
//        super.loadView()
//
//        self.webView = WKWebView()
//        self.view.addSubview(self.webView!)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: self.view.frame, configuration:config)
        self.view.addSubview(self.webView)

        var url = NSURL(string:"http://ello.co/")
        var req = NSURLRequest(URL:url!)
        self.webView.loadRequest(req)

//        self.webView!.loadHTMLString("yo", baseURL:NSURL(string:"/") )
//        self.view?.backgroundColor = UIColor.redColor()
//        self.webView?.backgroundColor = UIColor.blueColor()
    }
    
    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> NotificationsViewController {
        return storyboard.controllerWithID(.Notifications) as NotificationsViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
