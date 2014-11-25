//
//  DiscoverViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class DiscoverViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = DiscoverViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = DiscoverViewController.instantiateFromStoryboard()
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a DiscoverViewController", {
                expect(controller).to(beAKindOf(DiscoverViewController.self))
            })
        })
    }
}

