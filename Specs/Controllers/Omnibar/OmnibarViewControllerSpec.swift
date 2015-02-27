//
//  OmnibarViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = OmnibarViewController()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization", {

            beforeEach({
                controller = OmnibarViewController()
            })

            it("can be instantiated") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a OmnibarViewController", {
                expect(controller).to(beAKindOf(OmnibarViewController.self))
            })
        })
    }
}