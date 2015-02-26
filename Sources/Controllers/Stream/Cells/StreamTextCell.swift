//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

class StreamTextCell: UICollectionViewCell, UIWebViewDelegate {

    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?

    var calculatedHeight:CGFloat = 0.0

    override func layoutSubviews() {
        self.webView.frame = self.bounds
        super.layoutSubviews()
        webView.scrollView.scrollEnabled = false
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitUserSelect='none';")
        webView.stringByEvaluatingJavaScriptFromString("document.documentElement.style.webkitTouchCallout='none';")
        UIView.animateWithDuration(0.15, animations: {
            self.contentView.alpha = 1.0
        })
    }
}
