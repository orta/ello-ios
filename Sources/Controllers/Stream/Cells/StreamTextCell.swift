//
//  StreamTextCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit
import Foundation

public class StreamTextCell: StreamRegionableCell, UIWebViewDelegate {
    static let reuseIdentifier = "StreamTextCell"

    typealias WebContentReady = (webView : UIWebView) -> Void

    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    var userDelegate: UserDelegate?
    var webContentReady: WebContentReady?

    override public func awakeFromNib() {
        super.awakeFromNib()
        webView.scrollView.scrollEnabled = false
        webView.scrollView.scrollsToTop = false

        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: "imageDoubleTapped")
        webView.addGestureRecognizer(doubleTapGesture)

        let singleTapGesture = UITapGestureRecognizer()
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.addTarget(self, action: "imageTapped")
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        webView.addGestureRecognizer(singleTapGesture)
    }

    @IBAction func imageTapped() {
        print("=============== \(__FILE__) line \(__LINE__) ===============")
    }

    @IBAction func imageDoubleTapped() {
        print("=============== \(__FILE__) line \(__LINE__) ===============")
    }

    func onWebContentReady(handler: WebContentReady?) {
        webContentReady = handler
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        webView.stopLoading()
    }

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.URL?.scheme
            where scheme == "default"
        {
            userDelegate?.userTappedText(self)
            return false
        }
        else {
            return ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
        }
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        webContentReady?(webView: webView)
    }
}
