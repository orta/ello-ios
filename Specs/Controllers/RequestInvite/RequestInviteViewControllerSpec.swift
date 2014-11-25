//
//  RequestInviteViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class RequestInviteViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = RequestInviteViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = RequestInviteViewController.instantiateFromStoryboard()
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a RequestInviteViewController", {
                expect(controller).to(beAKindOf(RequestInviteViewController.self))
            })
        })
    }
}
