//
//  UIWebView.swift
//  Ello
//
//  Created by Colin Gray on 3/25/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public extension UIWebView {

    func windowContentSize() -> CGSize? {
        if let jsWidth = self.stringByEvaluatingJavaScriptFromString("(document.getElementById('post-container') || document.getElementByTagName('div')[0] || document.body).offsetWidth") {
            if let jsHeight = self.stringByEvaluatingJavaScriptFromString("(document.getElementById('post-container') || document.getElementByTagName('div')[0] || document.body).offsetHeight") {
                let width = CGFloat((jsWidth as NSString).doubleValue)
                let height = CGFloat((jsHeight as NSString).doubleValue)
                return CGSize(width: width, height: height)
            }
        }
        return nil
    }
}
