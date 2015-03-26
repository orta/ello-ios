//
//  UIWebViewSpecs.swift
//  Ello
//
//  Created by Colin Gray on 3/25/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class UIWebViewSpecs: QuickSpec, UIWebViewDelegate {
    var webView: UIWebView!

    override func spec() {
        describe("-windowContentSize") {
            beforeEach() {
                let html = "<div><img style=\"width: 100pt; height: 100pt;\" width=\"100\" height=\"100\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg==\" /></div>"
                self.webView = UIWebView(frame: CGRectZero)
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
                self.webView.delegate = self
            }
            it("should return the size") {
                if let size = self.webView.windowContentSize() {
                    expect(size.width).toEventually(beGreaterThanOrEqualTo(CGFloat(100)), timeout: 2)
                    expect(size.height).toEventually(beGreaterThanOrEqualTo(CGFloat(100)), timeout: 2)
                }
                else {
                    fail("no size returned from windowContentSize")
                }
            }
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        println("size: \(webView.windowContentSize())")
    }
}
