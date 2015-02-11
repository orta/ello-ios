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

        var user = User(name: "Ello", userId: "42", username: "ello", avatarURL: nil,
            experimentalFeatures: false, href: "/api/edge/users/42",
            relationshipPriority: "self", followersCount: 1, postsCount: 2,
            followingCount: 3, posts: [])
        var controller = ProfileViewController(user: user)

        describe("initialization", {

            it("can be instantiated") {
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

