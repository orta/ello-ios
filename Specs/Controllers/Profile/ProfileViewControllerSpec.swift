//
//  ProfileViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ProfileViewControllerSpec: QuickSpec {
    override func spec() {

        var user: User = stub(["id": "42"])
        var controller = ProfileViewController(userParam: user.id)

        describe("initialization") {

            it("can be instantiated") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a ProfileViewController") {
                expect(controller).to(beAKindOf(ProfileViewController.self))
            }

        }
    }
}
