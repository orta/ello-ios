//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

class StreamTextCell: UICollectionViewCell, WKNavigationDelegate {

    let webView:WKWebView

    var calculatedHeight:CGFloat = 120.0

    required init(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRectZero, configuration:config)
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if webView.superview == nil {
            self.contentView.addSubview(webView)
            webView.navigationDelegate = self
        }
        webView.frame = self.contentView.frame
    }


    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        println("didCommitNavigation")
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        println("didFinishNavigation")
    }
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        println("didFailNavigation")
    }


    private func setup() {
//        println(frame)
//        webView.frame = contentView.frame
//        self.internalWebView.backgroundColor = UIColor.blueColor()
//        self.contentView.backgroundColor = UIColor.redColor()
    }

//    func webView() -> WKWebView {
//        return webView
//    }

//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
//        let newSize = CGSize(width: UIScreen.screenWidth(), height: layoutAttributes.size.height)
//        var newFrame = attributes.frame
//        newFrame.size.height = newSize.height
//        newFrame.size.width = newSize.width
//        attributes.frame = newFrame
//        return attributes
//    }

}
