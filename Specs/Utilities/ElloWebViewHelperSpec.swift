//
//  ElloWebViewHelperSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ElloWebViewHelperSpec: QuickSpec {

    override func spec() {

        describe("handleRequest") {

            context("outside web view") {

                it("returns false with ello://notifications") {
                    var request = NSURLRequest(URL: NSURL(string: "ello://notifications")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns false with mailto:archer@isis.com") {
                    var request = NSURLRequest(URL: NSURL(string: "mailto:archer@isis.com")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://ello.co/downloads") {
                    var request = NSURLRequest(URL: NSURL(string: "http://ello.co/downloads")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://ello.co/wtf") {
                    var request = NSURLRequest(URL: NSURL(string: "http://ello.co/wtf")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://wallpapers.ello.co/anything") {
                    var request = NSURLRequest(URL: NSURL(string: "http://wallpapers.ello.co/anything")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://www.google.com") {
                    var request = NSURLRequest(URL: NSURL(string: "http://www.google.com")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == false
                }

                it("returns true with file://path_to_something") {
                    var request = NSURLRequest(URL: NSURL(string: "file://path_to_something")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil)) == true
                }

            }

            context("inside web view") {

                it("returns true with http://ello.co/downloads") {
                    var request = NSURLRequest(URL: NSURL(string: "http://ello.co/downloads")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://ello.co/wtf") {
                    var request = NSURLRequest(URL: NSURL(string: "http://ello.co/wtf")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://wallpapers.ello.co/anything") {
                    var request = NSURLRequest(URL: NSURL(string: "http://wallpapers.ello.co/anything")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://www.google.com") {
                    var request = NSURLRequest(URL: NSURL(string: "http://www.google.com")!)
                    expect(ElloWebViewHelper.handleRequest(request, webLinkDelegate: nil, fromWebView: true)) == true
                }

            }
        }
    }
}
