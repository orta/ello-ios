//
//  ProfileViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class ProfileViewControllerSpec: QuickSpec {
    override func spec() {

        let storyboard = UIStoryboard.iPhone()
        var controller = ProfileViewController.instantiateFromStoryboard(storyboard)
        describe("initialization", {

            beforeEach({
                controller = ProfileViewController.instantiateFromStoryboard(storyboard)
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a ProfileViewController", {
                expect(controller).to(beAKindOf(ProfileViewController.self))
            })
        })
    }
}

