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
        var subject = ProfileViewController(userParam: user.id)

        describe("initialization") {

            it("can be instantiated") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a ProfileViewController") {
                expect(subject).to(beAKindOf(ProfileViewController.self))
            }

        }

        describe("viewDidAppear(:_)") {

            it("does not update the top inset") {
                subject.viewDidAppear(false)
                expect(subject.streamViewController.contentInset.top) == 0
            }
        }
    }
}
