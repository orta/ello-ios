//
//  ElloWebBrowserViewControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 5/4/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ElloWebBrowserViewControllerSpec: QuickSpec {
    override func spec() {
        describe("instantiating an ElloWebBrowserViewControllerSpec") {
            it("is easy to create a navigation controller w/ browser") {
                let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
                expect(nav.rootWebBrowser()).to(beAKindOf(ElloWebBrowserViewController))
            }
            it("is easy to create a navigation controller w/ custom browser") {
                let browser = ElloWebBrowserViewController()
                let nav = ElloWebBrowserViewController.navigationControllerWithBrowser(browser)
                expect(nav.rootWebBrowser()).to(equal(browser))
            }
            it("has a fancy done button") {
                let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
                let browser: ElloWebBrowserViewController = nav.rootWebBrowser() as! ElloWebBrowserViewController
                let xButton = browser.navigationItem.rightBarButtonItem!
                expect(xButton.title).to(equal("\u{2573}"))
            }
        }
    }
}
