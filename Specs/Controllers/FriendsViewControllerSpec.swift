//
//  FriendsViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class FriendsViewControllerSpec: QuickSpec {
    override func spec() {

        let storyboard = UIStoryboard.iPhone()
        var controller = FriendsViewController.instantiateFromStoryboard(storyboard)
        describe("initialization", {

            beforeEach({
                controller = FriendsViewController.instantiateFromStoryboard(storyboard)
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a FriendsViewController", {
                expect(controller).to(beAKindOf(FriendsViewController.self))
            })
        })
    }
}