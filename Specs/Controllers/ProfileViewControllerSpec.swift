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

        var user = User(avatarURL: nil,
            coverImageURL: nil,
            experimentalFeatures: false,
            followersCount: 1,
            followingCount: 3,
            href: "/api/edge/users/42",
            name:  "Ello",
            posts: [],
            postsCount: 2,
            relationshipPriority: "self",
            userId: "42",
            username: "ello",
            formattedShortBio: "formatted test bio")

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

