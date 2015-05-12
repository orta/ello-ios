//
//  ElloNavigationControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ElloNavigationControllerSpec: QuickSpec {
    override func spec() {
        var controller = ElloNavigationController()

        describe("NotificationsViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.Notifications) as! ElloNavigationController
                controller.setProfileData(User.stub(["id": "fakeuser"]))
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }

        describe("ProfileViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.Profile) as! ElloNavigationController
                controller.setProfileData(User.stub(["id": "fakeuser"]))
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }

        describe("OmnibarViewController NavigationController") {
            beforeEach() {
                controller = UIStoryboard.storyboardWithId(.Omnibar) as! ElloNavigationController
                controller.setProfileData(User.stub(["id": "fakeuser"]))
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())
            }

            it("has a selected tab bar item") {
               expect(controller.tabBarItem!.selectedImage).notTo(beNil())
            }
        }
    }
}
