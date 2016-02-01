//
//  ProfileViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

@testable import Ello
import Moya
import Quick
import Nimble


class ProfileViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ProfileViewController") {

            describe("initialization from storyboard") {
                let user: User = stub(["id": "42"])
                let subject = ProfileViewController(userParam: user.id)

                it("can be instantiated") {
                    expect(subject).notTo(beNil())
                }

                describe("IBOutlets") {
                    beforeEach {
                        showController(subject)
                    }

                    it("has navigationBar") {
                        expect(subject.navigationBar).toNot(beNil())
                    }
                    it("has noPostsView") {
                        expect(subject.noPostsView).toNot(beNil())
                    }
                    it("has noPostsHeader") {
                        expect(subject.noPostsHeader).toNot(beNil())
                    }
                    it("has noPostsBody") {
                        expect(subject.noPostsBody).toNot(beNil())
                    }
                    it("has navigationBarTopConstraint") {
                        expect(subject.navigationBarTopConstraint).toNot(beNil())
                    }
                    it("has coverImage") {
                        expect(subject.coverImage).toNot(beNil())
                    }
                    it("has coverImageHeight") {
                        expect(subject.coverImageHeight).toNot(beNil())
                    }
                    it("has noPostsViewHeight") {
                        expect(subject.noPostsViewHeight).toNot(beNil())
                    }
                }

            }

            describe("contentInset") {
                let user: User = stub(["id": "42"])
                let subject = ProfileViewController(userParam: user.id)

                beforeEach {
                    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
                    showController(subject)
                }

                it("does not update the top inset") {
                    expect(subject.streamViewController.contentInset.top) == 0
                }
            }

            context("when displaying the currentUser") {
                var user: User!
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    user = User.stub(["id": "42"])
                    currentUser = User.stub(["id": "42"])
                    subject = ProfileViewController(user: user)
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("does not have a 'more following options' Button") {
                    let rightButtons = subject.elloNavigationItem.rightBarButtonItems
                    expect(rightButtons?.count ?? 0) == 0
                }
            }

            context("when NOT displaying the currentUser") {
                var user: User!
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    user = User.stub(["id": "42"])
                    currentUser = User.stub(["id": "not42"])
                    subject = ProfileViewController(user: user)
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("has a 'share' Button") {
                    let shareButton = subject.elloNavigationItem.rightBarButtonItems?[0]
                    expect(shareButton).toNot(beNil())
                }

                it("has a 'more following options' Button") {
                    let moreButton = subject.elloNavigationItem.rightBarButtonItems?[1]
                    expect(moreButton).toNot(beNil())
                }
            }

            context("when displaying a private user") {
                var user: User!
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    user = User.stub(["id": "42", "hasSharingEnabled": false])
                    currentUser = User.stub(["id": "not42"])
                    subject = ProfileViewController(user: user)
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("does not have a 'share' Button") {
                    let count = subject.elloNavigationItem.rightBarButtonItems?.count
                    expect(count) == 1
                }

                it("has a 'more following options' Button") {
                    let moreButton = subject.elloNavigationItem.rightBarButtonItems?[0]
                    expect(moreButton).toNot(beNil())
                }
            }

            describe("tapping more button") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    user = User.stub(["id": "42"])
                    subject = ProfileViewController(userParam: user.id)
                    showController(subject)
                }

                it("launches the block modal") {
                    subject.moreButtonTapped()
                    let presentedVC = subject.presentedViewController
                    expect(presentedVC).notTo(beNil())
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController))
                }
            }


            context("with successful request") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    showController(subject)
                    user = subject.user!
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Block))
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Mute))
                    }

                    it("selected block") {
                        user.relationshipPriority = .Block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected mute") {
                        user.relationshipPriority = .Mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                }
            }

            context("with failed request") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    showController(subject)
                    user = subject.user!
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected block") {
                        user.relationshipPriority = .Block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Block))
                    }

                    it("selected mute") {
                        user.relationshipPriority = .Mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Mute))
                    }
                }
            }

            xcontext("snapshots") {
                let subject = ProfileViewController(userParam: "42")
                validateAllSnapshots(subject)
            }

            xcontext("snapshots - currentUser") {
                let user: User = stub([:])
                let subject = ProfileViewController(user: user)
                beforeEach {
                    showController(subject)
                    subject.currentUser = user
                    subject.updateCurrentUser(user)
                }
                validateAllSnapshots(subject)
            }
        }
    }
}
