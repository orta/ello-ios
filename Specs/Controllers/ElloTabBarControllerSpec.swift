
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

        var subject: ElloTabBarController!
        var tabBarItem: UITabBarItem
        let child1root = UIViewController()
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 2000, height: 2000)
        child1root.view.addSubview(scrollView)
        let child1 = UINavigationController(rootViewController: child1root)
        tabBarItem = child1.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        let child2 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child2.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        let child3 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child3.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        let child4 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child4.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        let child5 = UINavigationController(rootViewController: UIViewController())
        tabBarItem = child5.tabBarItem
        tabBarItem.image = UIImage.imageWithColor(.blackColor())
        tabBarItem.selectedImage = UIImage.imageWithColor(.blackColor())

        describe("initialization") {

            beforeEach() {
                subject = ElloTabBarController.instantiateFromStoryboard()
            }

            it("can be instantiated from storyboard") {
                expect(subject).notTo(beNil())
            }

            it("is a ElloTabBarController") {
                expect(subject).to(beAKindOf(ElloTabBarController.self))
            }

        }

        describe("-viewDidLoad") {

            beforeEach() {
                subject = ElloTabBarController.instantiateFromStoryboard()
                _ = subject.view
            }

            it("sets friends as the selected tab") {
                if let navigationController = subject.selectedViewController as? ElloNavigationController {
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
                subject = ElloTabBarController.instantiateFromStoryboard()
                let children = subject.childViewControllers
                for child in children {
                    child.removeFromParentViewController()
                }
                subject.addChildViewController(child1)
                subject.addChildViewController(child2)
                subject.addChildViewController(child3)
                subject.addChildViewController(child4)
                subject.addChildViewController(child5)
                _ = subject.view
            }

            it("should load child1") {
                subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1))
                expect(child1.isViewLoaded()).to(beTrue())
            }

            it("should load child2") {
                subject.tabBar(subject.tabBar, didSelectItem: child2.tabBarItem)
                expect(subject.selectedViewController).to(equal(child2))
                expect(child2.isViewLoaded()).to(beTrue())
            }

            it("should load child3") {
                subject.tabBar(subject.tabBar, didSelectItem: child3.tabBarItem)
                expect(subject.selectedViewController).to(equal(child3))
                expect(child3.isViewLoaded()).to(beTrue())
            }

            describe("tapping the item twice") {
                it("should pop to the root view controller") {
                    let vc1 = child2.topViewController
                    let vc2 = UIViewController()
                    child2.pushViewController(vc2, animated: false)

                    subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child1))

                    subject.tabBar(subject.tabBar, didSelectItem: child2.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child2))
                    expect(child2.topViewController).to(equal(vc2))

                    subject.tabBar(subject.tabBar, didSelectItem: child2.tabBarItem)
                    expect(child2.topViewController).to(equal(vc1))
                }

                // BAH!  I HATE WRITING IOS SPECS SO MUCH!
                // this code DOES pass when tested by a human.  But when the
                // code is run synchronously, as in the spec, the view hierarchy
                // is not set, and the 'tapping twice' behavior doesn't change the content
                // offset all the way to 0.
                xit("should scroll to the top") {
                    showController(subject)
                    let vc = child1.topViewController
                    scrollView.contentOffset = CGPoint(x: 0, y: 200)

                    subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                    expect(subject.selectedViewController).to(equal(child1))
                    expect(child1.topViewController).to(equal(vc))

                    subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                    expect(child1.topViewController).to(equal(vc))
                    expect(scrollView.contentOffset).toEventually(equal(CGPoint(x: 0, y: 0)))
                }

                // :sad face:, same issue, the async UIScrollView doesn't play nicely
                xcontext("stream tab") {
                    context("red dot visible") {
                        it("posts a NewContentNotifications.reloadStreamContent"){
                            showController(subject)
                            var reloadPosted = false
                            subject.streamsDot?.hidden = false
                            _ = NotificationObserver(notification: NewContentNotifications.reloadStreamContent) {
                                _ in
                                reloadPosted = true
                            }
                            let vc = child3.topViewController

                            subject.tabBar(subject.tabBar, didSelectItem: child3.tabBarItem)
                            expect(subject.selectedViewController).to(equal(child3))
                            expect(child3.topViewController).to(equal(vc))

                            subject.tabBar(subject.tabBar, didSelectItem: child3.tabBarItem)
                            expect(child3.topViewController).to(equal(vc))
                            expect(reloadPosted) == true
                        }
                    }
                }
            }
        }

        context("showing the narration") {
            var prevTabValues: [ElloTab: Bool?]!

            beforeEach() {
                prevTabValues = [
                    ElloTab.Discover: GroupDefaults[ElloTab.Discover.narrationDefaultKey].bool,
                    ElloTab.Notifications: GroupDefaults[ElloTab.Notifications.narrationDefaultKey].bool,
                    ElloTab.Stream: GroupDefaults[ElloTab.Stream.narrationDefaultKey].bool,
                    ElloTab.Profile: GroupDefaults[ElloTab.Profile.narrationDefaultKey].bool,
                    ElloTab.Omnibar: GroupDefaults[ElloTab.Omnibar.narrationDefaultKey].bool
                ]

                subject = ElloTabBarController.instantiateFromStoryboard()
                let children = subject.childViewControllers
                for child in children {
                    child.removeFromParentViewController()
                }
                subject.addChildViewController(child1)
                subject.addChildViewController(child2)
                subject.addChildViewController(child3)
                subject.addChildViewController(child4)
                subject.addChildViewController(child5)
                _ = subject.view
            }
            afterEach {
                for (tab, value) in prevTabValues {
                    GroupDefaults[tab.narrationDefaultKey] = value
                }
            }

            it("should never change the key") {
                expect(ElloTab.Discover.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationDiscover"
                expect(ElloTab.Notifications.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationNotifications"
                expect(ElloTab.Stream.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationStream"
                expect(ElloTab.Profile.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationProfile"
                expect(ElloTab.Omnibar.narrationDefaultKey) == "ElloTabBarControllerDidShowNarrationOmnibar"
            }

            it("should set the narration values") {
                let tab = ElloTab.Stream
                ElloTabBarController.didShowNarration(tab, false)
                expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beFalse())
                ElloTabBarController.didShowNarration(tab, true)
                expect(GroupDefaults[tab.narrationDefaultKey].bool).to(beTrue())
            }
            it("should get the narration values") {
                let tab = ElloTab.Stream
                GroupDefaults[tab.narrationDefaultKey] = false
                expect(ElloTabBarController.didShowNarration(tab)).to(beFalse())
                GroupDefaults[tab.narrationDefaultKey] = true
                expect(ElloTabBarController.didShowNarration(tab)).to(beTrue())
            }
            it("should NOT show the narrationView when changing to a tab that has already shown the narrationView") {
                ElloTabBarController.didShowNarration(.Discover, true)
                ElloTabBarController.didShowNarration(.Notifications, true)
                ElloTabBarController.didShowNarration(.Stream, true)
                ElloTabBarController.didShowNarration(.Profile, true)
                ElloTabBarController.didShowNarration(.Omnibar, true)

                subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1))
                expect(subject.shouldShowNarration).to(beFalse())
                expect(subject.isShowingNarration).to(beFalse())
            }
            it("should show the narrationView when changing to a tab that hasn't shown the narrationView yet") {
                ElloTabBarController.didShowNarration(.Discover, false)
                ElloTabBarController.didShowNarration(.Notifications, false)
                ElloTabBarController.didShowNarration(.Stream, false)
                ElloTabBarController.didShowNarration(.Profile, false)
                ElloTabBarController.didShowNarration(.Omnibar, false)

                subject.tabBar(subject.tabBar, didSelectItem: child1.tabBarItem)
                expect(subject.selectedViewController).to(equal(child1), description: "selectedViewController")
                expect(subject.shouldShowNarration).to(beTrue(), description: "shouldShowNarration")
                expect(subject.isShowingNarration).to(beTrue(), description: "isShowingNarration")
            }
        }

    }
}
