//
//  RelationshipControlSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class RelationshipControlSpec: QuickSpec {
    override func spec() {

        let subject: RelationshipControl! = RelationshipControl(coder: NSKeyedUnarchiver(forReadingWithData: NSData()))
        var presentingController = UIViewController()
        self.showController(presentingController)
        var relationshipController = RelationshipController(presentingController: presentingController)

        describe("@relationship") {

            it("sets button state properly when set to friend") {
                subject.relationshipPriority = .Following
                expect(subject.label.text) == "Friend"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.blackColor()
            }

            it("sets button state properly when set to noise") {
                subject.relationshipPriority = .Noise
                expect(subject.label.text) == "Noise"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.blackColor()
            }

            it("sets button state properly when set to mute") {
                subject.relationshipPriority = .Mute
                expect(subject.label.text) == "Muted"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.redColor()
            }

            it("sets button state properly when set to anything else") {
                for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                    subject.relationshipPriority = relationshipPriority
                    expect(subject.label.text) == "Follow"
                    expect(subject.mainButtonBackground.backgroundColor) == UIColor.whiteColor()
                }
            }
        }

        describe("button targets") {

            beforeEach {
                presentingController = UIViewController()
                self.showController(presentingController)
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

                describe("tapping the main button") {

                    context("RelationshipPriority.Following") {

                        it("launches the following/follow as modal") {
                            subject.relationshipPriority = .Following
                            subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as? AlertViewController
                            expect(presentedVC).notTo(beNil())
                            expect(presentedVC?.message) == "Following as"
                            expect(presentedVC!.actions[0].title) == "Friend"
                            expect(presentedVC!.actions[0].style).to(equal(ActionStyle.Dark))
                            expect(presentedVC!.actions[1].title) == "Noise"
                            expect(presentedVC!.actions[1].style).to(equal(ActionStyle.White))
                            expect(presentedVC!.actions[2].title) == "Unfollow"
                            expect(presentedVC!.actions[2].style).to(equal(ActionStyle.Light))
                            expect(presentedVC!.actions.count) == 3
                        }
                    }

                    context("RelationshipPriority.Noise") {

                        it("launches the following/follow as modal") {
                            subject.relationshipPriority = .Noise
                            subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
                            let presentedVC = relationshipController.presentingController.presentedViewController as? AlertViewController
                            expect(presentedVC).notTo(beNil())
                            expect(presentedVC?.message) == "Following as"
                            expect(presentedVC!.actions[0].title) == "Friend"
                            expect(presentedVC!.actions[0].style).to(equal(ActionStyle.White))
                            expect(presentedVC!.actions[1].title) == "Noise"
                            expect(presentedVC!.actions[1].style).to(equal(ActionStyle.Dark))
                            expect(presentedVC!.actions[2].title) == "Unfollow"
                            expect(presentedVC!.actions[2].style).to(equal(ActionStyle.Light))
                            expect(presentedVC!.actions.count) == 3
                        }
                    }

                    context("RelationshipPriority.Inactive|None|Null|Me") {

                        it("launches the following/follow as modal") {
                            for relationshipPriority in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                                subject.relationshipPriority = relationshipPriority
                                subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
                                let presentedVC = relationshipController.presentingController.presentedViewController as? AlertViewController
                                expect(presentedVC).notTo(beNil())
                                expect(presentedVC?.message) == "Follow as"
                                expect(presentedVC!.actions[0].title) == "Friend"
                                expect(presentedVC!.actions[0].style).to(equal(ActionStyle.White))
                                expect(presentedVC!.actions[1].title) == "Noise"
                                expect(presentedVC!.actions[1].style).to(equal(ActionStyle.White))
                                expect(presentedVC!.actions.count) == 2
                            }
                        }
                    }
                }
            }

            context("muted") {

                describe("tapping the main button") {

                    it("launches the block modal") {
                        subject.relationshipPriority = .Mute
                        subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
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
