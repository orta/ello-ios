//
//  ElloTabBarControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ElloTabBarControllerSpec: QuickSpec {
    override func spec() {

        var controller = ElloTabBarController.instantiateFromStoryboard()

        describe("initialization") {

            beforeEach() {
                controller = ElloTabBarController.instantiateFromStoryboard()
            }

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a ElloTabBarController") {
                expect(controller).to(beAKindOf(ElloTabBarController.self))
            }

        }

        describe("-viewDidLoad") {

            beforeEach() {
                controller = ElloTabBarController.instantiateFromStoryboard()
                let view = controller.view
            }

            it("sets friends as the selected tab") {
                if let navigationController = controller.selectedViewController as? ElloNavigationController {
                    navigationController.currentUser = User.fakeCurrentUser("foo")
                    if let firstController = navigationController.topViewController as? BaseElloViewController {
                        expect(firstController).to(beAKindOf(StreamContainerViewController.self))
                    }
                    else {
                        fail("navigation controller doesn't have a topViewController, or it isn't a BaseElloViewController")
                    }
                }
                else {
                    fail("tab bar controller does not have a selectedViewController, or it isn't a ElloNavigationController")
                }
            }

        }
    }
}
