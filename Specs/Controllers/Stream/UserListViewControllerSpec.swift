//
//  UserListViewControllerSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import Quick
import Nimble

class UserListViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = UserListViewController(endpoint: ElloAPI.UserStreamFollowers(userId: "666"), title: "Followers")
        let userListController = UserListController(presentingController: UIViewController())


        describe("initialization") {

            it("can be instantiated") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a StreamableViewController") {
                expect(subject).to(beAKindOf(StreamableViewController.self))
            }

            it("is a UserListViewController") {
                expect(subject).to(beAKindOf(UserListViewController.self))
            }

            it("sets the title") {
                expect(subject.title) == "Followers"
            }
        }
    }
}
