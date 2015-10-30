//
//  RelationshipControlSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble
import Moya


class RelationshipControlSpec: QuickSpec {
    override func spec() {
        describe("RelationshipControl") {
            let subject = RelationshipControl()
            var presentingController = UIViewController()
            showController(presentingController)
            var relationshipController = RelationshipController(presentingController: presentingController)

            describe("@relationship") {

                it("sets button state properly when set to friend") {
                    subject.relationshipPriority = .Following
                    expect(subject.followingButton.currentTitle) == "Following"
                    expect(subject.followingButton.backgroundColor) == UIColor.blackColor()
                }

                it("sets button state properly when set to noise") {
                    subject.relationshipPriority = .Starred
                    expect(subject.followingButton.currentTitle) == "Following"
                    expect(subject.followingButton.backgroundColor) == UIColor.blackColor()
                }

                it("sets button state properly when set to mute") {
                    subject.relationshipPriority = .Mute
                    expect(subject.followingButton.currentTitle) == "Muted"
                    expect(subject.followingButton.backgroundColor) == UIColor.redColor()
                }

                it("sets button state properly when set to anything else") {
                    for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                        subject.relationshipPriority = relationshipPriority
                        expect(subject.followingButton.currentTitle) == "Follow"
                        expect(subject.followingButton.backgroundColor) == UIColor.whiteColor()
                    }
                }
            }

            describe("intrinsicContentSize()") {
                it("should calculate when showMoreButton=false showStarredButton=false") {
                    subject.showMoreButton = false
                    subject.showStarredButton = false
                    let expectedSize = CGSize(width: 105, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.moreButton.frame) == CGRectZero
                    expect(subject.starredButton.frame) == CGRectZero
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
                it("should calculate when showMoreButton=true showStarredButton=false") {
                    subject.showMoreButton = true
                    subject.showStarredButton = false
                    let expectedSize = CGSize(width: 140, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.moreButton.frame) == CGRect(x: 0, y: 0, width: 30, height: 30)
                    expect(subject.starredButton.frame) == CGRectZero
                    expect(subject.followingButton.frame) == CGRect(x: 35, y: 0, width: 105, height: 30)
                }
                it("should calculate when showMoreButton=false showStarredButton=true") {
                    subject.showMoreButton = false
                    subject.showStarredButton = true
                    let expectedSize = CGSize(width: 135, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.moreButton.frame) == CGRectZero
                    expect(subject.starredButton.frame) == CGRect(x: 105, y: 0, width: 30, height: 30)
                    expect(subject.followingButton.frame) == CGRect(x: 0, y: 0, width: 105, height: 30)
                }
                it("should calculate when showMoreButton=true showStarredButton=true") {
                    subject.showMoreButton = true
                    subject.showStarredButton = true
                    let expectedSize = CGSize(width: 170, height: 30)
                    expect(subject.intrinsicContentSize()) == expectedSize
                    subject.frame = CGRect(origin: CGPointZero, size: expectedSize)
                    subject.layoutIfNeeded()
                    expect(subject.moreButton.frame) == CGRect(x: 0, y: 0, width: 30, height: 30)
                    expect(subject.starredButton.frame) == CGRect(x: 140, y: 0, width: 30, height: 30)
                    expect(subject.followingButton.frame) == CGRect(x: 35, y: 0, width: 105, height: 30)
                }
            }

            describe("button targets") {

                beforeEach {
                    presentingController = UIViewController()
                    showController(presentingController)
                    relationshipController = RelationshipController(presentingController: presentingController)
                    subject.relationshipDelegate = relationshipController
                }

                describe("tapping more button") {

                    it("launches the block modal") {
                        subject.relationshipPriority = .Following
                        subject.moreButton.sendActionsForControlEvents(.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as? BlockUserModalViewController
                        expect(presentedVC).notTo(beNil())
                    }
                }

                context("not muted") {

                    describe("tapping the following button") {

                        for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("unfollows the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.Following
                                }
                            }
                        }

                        context("RelationshipPriority.Following") {

                            it("unfollows the user") {
                                subject.relationshipPriority = .Following
                                subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Inactive
                            }
                        }

                        context("RelationshipPriority.Starred") {

                            it("unfollows the user") {
                                subject.relationshipPriority = .Starred
                                subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Inactive
                            }
                        }
                    }

                    describe("tapping the starred button") {

                        for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null] {
                            context("RelationshipPriority.\(relationshipPriority)") {

                                it("stars the user") {
                                    subject.relationshipPriority = relationshipPriority
                                    subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
                                    expect(subject.relationshipPriority) == RelationshipPriority.Starred
                                }
                            }
                        }

                        context("RelationshipPriority.Following") {

                            it("stars the user") {
                                subject.relationshipPriority = .Following
                                subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Starred
                            }
                        }

                        context("RelationshipPriority.Starred") {

                            it("unstars the user") {
                                subject.relationshipPriority = .Starred
                                subject.starredButton.sendActionsForControlEvents(.TouchUpInside)
                                expect(subject.relationshipPriority) == RelationshipPriority.Following
                            }
                        }
                    }
                }

                context("muted") {

                    describe("tapping the main button") {

                        it("launches the block modal") {
                            subject.relationshipPriority = .Mute
                            subject.followingButton.sendActionsForControlEvents(.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as? BlockUserModalViewController
                            expect(presentedVC).notTo(beNil())
                        }
                    }

                }

                context("with successful request") {

                    beforeEach {
                        ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.endpointClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    }

                    describe("@moreButton") {
                        it("not selected block") {
                            subject.relationshipPriority = .Inactive
                            subject.moreButton.sendActionsForControlEvents(.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Block))
                        }

                        it("not selected mute") {
                            subject.relationshipPriority = .Inactive
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Mute))
                        }

                        it("selected block") {
                            subject.relationshipPriority = .Block
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }

                        it("selected mute") {
                            subject.relationshipPriority = .Mute
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }

                    }
                }

                context("with failed request") {

                    beforeEach {
                        ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.errorEndpointsClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    }

                    describe("@moreButton") {
                        it("not selected block") {
                            subject.relationshipPriority = .Inactive
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }

                        it("not selected mute") {
                            subject.relationshipPriority = .Inactive
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }

                        it("selected block") {
                            subject.relationshipPriority = .Block
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Block))
                        }

                        it("selected mute") {
                            subject.relationshipPriority = .Mute
                            subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                            presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Mute))
                        }
                    }
                }
            }
        }
    }
}
