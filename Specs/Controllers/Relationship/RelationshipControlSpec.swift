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

        let subject = RelationshipControl(coder: NSKeyedUnarchiver(forReadingWithData: NSData()))
        var presentingController = UIViewController()
        self.showController(presentingController)
        var relationshipController = RelationshipController(presentingController: presentingController)

        describe("@relationship") {

            it("sets button state properly when set to friend") {
                subject.relationship = .Friend
                expect(subject.label.text) == "Friend"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.blackColor()
            }

            it("sets button state properly when set to noise") {
                subject.relationship = .Noise
                expect(subject.label.text) == "Noise"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.blackColor()
            }

            it("sets button state properly when set to mute") {
                subject.relationship = .Mute
                expect(subject.label.text) == "Muted"
                expect(subject.mainButtonBackground.backgroundColor) == UIColor.redColor()
            }

            it("sets button state properly when set to anything else") {
                for relationship in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                    subject.relationship = relationship
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
                    subject.relationship = .Friend
                    subject.moreButton.sendActionsForControlEvents(.TouchUpInside)
                    let presentedVC = relationshipController.presentingController.presentedViewController as? BlockUserModalViewController
                    expect(presentedVC).notTo(beNil())
                }
            }

            context("not muted") {

                describe("tapping the main button") {

                    context("RelationshipPriority.Friend") {

                        it("launches the following/follow as modal") {
                            subject.relationship = .Friend
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
                            expect(count(presentedVC!.actions)) == 3
                        }
                    }

                    context("RelationshipPriority.Noise") {

                        it("launches the following/follow as modal") {
                            subject.relationship = .Noise
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
                            expect(count(presentedVC!.actions)) == 3
                        }
                    }

                    context("RelationshipPriority.Inactive|None|Null|Me") {

                        it("launches the following/follow as modal") {
                            for relationship in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                                subject.relationship = relationship
                                subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
                                let presentedVC = relationshipController.presentingController.presentedViewController as? AlertViewController
                                expect(presentedVC).notTo(beNil())
                                expect(presentedVC?.message) == "Follow as"
                                expect(presentedVC!.actions[0].title) == "Friend"
                                expect(presentedVC!.actions[0].style).to(equal(ActionStyle.White))
                                expect(presentedVC!.actions[1].title) == "Noise"
                                expect(presentedVC!.actions[1].style).to(equal(ActionStyle.White))
                                expect(count(presentedVC!.actions)) == 2
                            }
                        }
                    }
                }
            }

            context("muted") {

                describe("tapping the main button") {

                    it("launches the block modal") {
                        subject.relationship = .Mute
                        subject.mainButton.sendActionsForControlEvents(.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as? BlockUserModalViewController
                        expect(presentedVC).notTo(beNil())
                    }
                }

            }

            context("with successful request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                describe("@moreButton") {
                    it("not selected block") {
                        subject.relationship = .Inactive
                        subject.moreButton.sendActionsForControlEvents(.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
                    }

                    it("not selected mute") {
                        subject.relationship = .Inactive
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
                    }

                    it("selected block") {
                        subject.relationship = .Block
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected mute") {
                        subject.relationship = .Mute
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                }
            }

            context("with failed request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                describe("@moreButton") {
                    it("not selected block") {
                        subject.relationship = .Inactive
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("not selected mute") {
                        subject.relationship = .Inactive
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected block") {
                        subject.relationship = .Block
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
                    }

                    it("selected mute") {
                        subject.relationship = .Mute
                        subject.moreButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
                    }
                }
            }
        }
    }
}
