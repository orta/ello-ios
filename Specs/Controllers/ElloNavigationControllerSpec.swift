//
//  ElloNavigationControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class ElloNavigationControllerSpec: QuickSpec {
    override func spec() {
        var controller = ElloNavigationController()

        describe("NotificationsViewController") {
            beforeEach() {
                controller = ElloNavigationController()
                controller.rootViewControllerName = ElloNavigationController.RootViewControllers.Notifications.rawValue
            }

            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())

//                let selectedImage:UIImage = controller.tabBarItem.valueForKey("selectedImage") as UIImage
//                expect(selectedImage).notTo(beNil())
            })
        }

        describe("ProfileViewController") {
            beforeEach() {
                controller = ElloNavigationController()
                controller.rootViewControllerName = ElloNavigationController.RootViewControllers.Profile.rawValue
            }

            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())

//                let selectedImage:UIImage = controller.tabBarItem.valueForKey("selectedImage") as UIImage
//                expect(selectedImage).notTo(beNil())
            })
        }
    }
}
