//
//  ElloTabBarControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import SwiftyUserDefaults
import Quick
import Nimble


class ElloTabBarControllerSpec: QuickSpec {
    override func spec() {

        var controller: ElloTabBarController!
        var tabBarItem: UITabBarItem
        var child1 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child1.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        var child2 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child2.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        var child3 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child3.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        var child4 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child4.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        var child5 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child5.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

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
                    navigationController.currentUser = User.stub(["username": "foo"])
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

        context("selecting tab bar items") {

            beforeEach() {
                controller = ElloTabBarController.instantiateFromStoryboard()
                let children = controller.childViewControllers as! [UIViewController]
                for child in children {
                    child.removeFromParentViewController()
                }
                controller.addChildViewController(child1)
                controller.addChildViewController(child2)
                controller.addChildViewController(child3)
                controller.addChildViewController(child4)
                controller.addChildViewController(child5)
                let view = controller.view
            }

            it("should load child1") {
                controller.tabBar(controller.tabBar, didSelectItem: child1.tabBarItem)
                expect(controller.selectedViewController).to(equal(child1))
                expect(child1.isViewLoaded()).to(beTrue())
            }

            it("should load child2") {
                controller.tabBar(controller.tabBar, didSelectItem: child2.tabBarItem)
                expect(controller.selectedViewController).to(equal(child2))
                expect(child2.isViewLoaded()).to(beTrue())
            }

            it("should load child3") {
                controller.tabBar(controller.tabBar, didSelectItem: child3.tabBarItem)
                expect(controller.selectedViewController).to(equal(child3))
                expect(child3.isViewLoaded()).to(beTrue())
            }

            it("tapping the item twice") {
                let vc1 = child2.topViewController
                let vc2 = UIViewController()
                child2.pushViewController(vc2, animated: false)

                controller.tabBar(controller.tabBar, didSelectItem: child1.tabBarItem)
                expect(controller.selectedViewController).to(equal(child1))

                controller.tabBar(controller.tabBar, didSelectItem: child2.tabBarItem)
                expect(controller.selectedViewController).to(equal(child2))
                expect(child2.topViewController).to(equal(vc2))

                controller.tabBar(controller.tabBar, didSelectItem: child2.tabBarItem)
                expect(child2.topViewController).to(equal(vc1))
            }
        }

        context("showing the narration") {
            beforeEach() {
                controller = ElloTabBarController.instantiateFromStoryboard()
                let children = controller.childViewControllers as! [UIViewController]
                for child in children {
                    child.removeFromParentViewController()
                }
                controller.addChildViewController(child1)
                controller.addChildViewController(child2)
                controller.addChildViewController(child3)
                controller.addChildViewController(child4)
                controller.addChildViewController(child5)
                let view = controller.view
            }
            it("should set the narration values") {
                let tab = ElloTab.Stream
                ElloTabBarController.didShowNarration(tab, false)
                expect(Defaults[tab.narrationDefaultKey].bool).to(beFalse())
                ElloTabBarController.didShowNarration(tab, true)
                expect(Defaults[tab.narrationDefaultKey].bool).to(beTrue())
            }
            it("should get the narration values") {
                let tab = ElloTab.Stream
                Defaults[tab.narrationDefaultKey] = false
                expect(ElloTabBarController.didShowNarration(tab)).to(beFalse())
                Defaults[tab.narrationDefaultKey] = true
                expect(ElloTabBarController.didShowNarration(tab)).to(beTrue())
            }
            it("should NOT show the narrationView when changing to a tab that has already shown the narrationView") {
                ElloTabBarController.didShowNarration(.Discovery, true)
                ElloTabBarController.didShowNarration(.Notifications, true)
                ElloTabBarController.didShowNarration(.Stream, true)
                ElloTabBarController.didShowNarration(.Profile, true)
                ElloTabBarController.didShowNarration(.Post, true)

                controller.tabBar(controller.tabBar, didSelectItem: child1.tabBarItem)
                expect(controller.selectedViewController).to(equal(child1))
                expect(controller.shouldShowNarration).toEventually(beFalse())
                expect(controller.isShowingNarration).toEventually(beFalse())
            }
            it("should show the narrationView when changing to a tab that hasn't shown the narrationView yet") {
                ElloTabBarController.didShowNarration(.Discovery, false)
                ElloTabBarController.didShowNarration(.Notifications, false)
                ElloTabBarController.didShowNarration(.Stream, false)
                ElloTabBarController.didShowNarration(.Profile, false)
                ElloTabBarController.didShowNarration(.Post, false)

                controller.tabBar(controller.tabBar, didSelectItem: child1.tabBarItem)
                expect(controller.selectedViewController).to(equal(child1))
                expect(controller.shouldShowNarration).toEventually(beTrue())
                expect(controller.isShowingNarration).toEventually(beTrue())
            }
        }

    }
}
