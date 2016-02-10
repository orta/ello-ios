//
//  ShareViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 2/9/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import ShareExtension
import Quick
import Nimble

class ShareViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ShareViewController") {
            var subject = ShareViewController()
            describe("initialization") {
                beforeEach {
                    controller = ShareViewController()
                }

                it("can be instantiated") {
                    expect(controller).notTo(beNil())
                }

                it("is a UIViewController") {
                    expect(controller).to(beAKindOf(UIViewController.self))
                }

                it("is a ShareViewController") {
                    expect(controller).to(beAKindOf(ShareViewController.self))
                }
            }
        }
    }
}
