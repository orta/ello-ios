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

        fdescribe("@relationship") {

            it("sets button state properly when set to friend") {
                subject.relationship = RelationshipPriority.Friend
                expect(subject.attributedNormalTitle.string) == "Friend"
                expect(subject.attributedSelectedTitle.string) == "Friend"
            }

            it("sets button state properly when set to noise") {
                subject.relationship = RelationshipPriority.Noise
                expect(subject.attributedNormalTitle.string) == "Noise"
                expect(subject.attributedSelectedTitle.string) == "Noise"
            }

            it("sets button state properly when set to anything else") {
                for relationship in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                    subject.relationship = relationship
                    expect(subject.attributedNormalTitle.string) == "+ Follow"
                    expect(subject.attributedSelectedTitle.string) == "+ Follow"
                }
            }
        }

//        describe("button targets") {
//
//            beforeEach {
//                presentingController = UIViewController()
//                self.showController(presentingController)
//                relationshipController = RelationshipController(presentingController: presentingController)
//                subject.relationshipDelegate = relationshipController
//            }
//
//            context("with successful request") {
//
//                beforeEach {
//                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
//                }
//
//                describe("@friendButton") {
//                    it("not selected") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Friend))
//                    }
//
//                    it("selected") {
//                        subject.relationship = RelationshipPriority.Friend
//                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//                }
//
//                describe("@noiseButton") {
//                    it("not selected") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Noise))
//                    }
//
//                    it("selected") {
//                        subject.relationship = RelationshipPriority.Noise
//                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//                }
//
//                describe("@blockButton") {
//                    it("not selected block") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
//                    }
//
//                    it("not selected mute") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
//                    }
//
//                    it("selected block") {
//                        subject.relationship = RelationshipPriority.Block
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                    it("selected mute") {
//                        subject.relationship = RelationshipPriority.Mute
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                }
//            }
//
//            context("with failed request") {
//
//                beforeEach {
//                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
//                }
//
//                describe("@friendButton") {
//                    it("not selected") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                    it("selected") {
//                        subject.relationship = RelationshipPriority.Friend
//                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Friend))
//                    }
//                }
//
//                describe("@noiseButton") {
//                    it("not selected") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                    it("selected") {
//                        subject.relationship = RelationshipPriority.Noise
//                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Noise))
//                    }
//                }
//
//                describe("@blockButton") {
//                    it("not selected block") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                    it("not selected mute") {
//                        subject.relationship = RelationshipPriority.Inactive
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
//                    }
//
//                    it("selected block") {
//                        subject.relationship = RelationshipPriority.Block
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
//                    }
//
//                    it("selected mute") {
//                        subject.relationship = RelationshipPriority.Mute
//                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
//                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
//                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
//                    }
//                }
//            }
//        }
    }
}
