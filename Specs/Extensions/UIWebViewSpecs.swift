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
    var size: CGSize = CGSize(width: 0, height: 0)

    override func spec() {
        xdescribe("-windowContentSize") {
            beforeEach() {
                let html = "<div id=\"post-container\"><img style=\"width: 100pt; height: 100pt;\" width=\"100\" height=\"100\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg==\" /></div>"
                self.webView = UIWebView(frame: CGRectZero)
                self.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
                self.webView.delegate = self
            }
            it("should return the size") {
                expect(self.size.width).toEventually(beGreaterThanOrEqualTo(CGFloat(100)), timeout: 5)
                expect(self.size.height).toEventually(beGreaterThanOrEqualTo(CGFloat(100)), timeout: 5)
            }
        }
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if let size = self.webView.windowContentSize() {
            self.size = size
        }
    }
}
