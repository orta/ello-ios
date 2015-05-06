//
//  RelationshipViewSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class RelationshipViewSpec: QuickSpec {
    override func spec() {

        let subject = RelationshipView(coder: NSKeyedUnarchiver(forReadingWithData: NSData()))
        subject.buildLargeButtons()
        var presentingController = UIViewController()
        self.showController(presentingController)
        var relationshipController = RelationshipController(presentingController: presentingController)

        describe("initialization") {

            it("sets IBOutlets") {
                expect(subject.friendButton).notTo(beNil())
                expect(subject.noiseButton).notTo(beNil())
                expect(subject.userId).notTo(beNil())
                expect(subject.userAtName).notTo(beNil())
            }

            it("can be instantiated from storyboard") {
                expect(subject).notTo(beNil())
            }

            it("is a RelationshipView") {
                expect(subject).to(beAKindOf(RelationshipView.self))
            }
        }

        describe("@relationship") {

            it("sets button state properly when set to mute") {
                subject.relationship = RelationshipPriority.Mute
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beTrue())
            }

            it("sets button state properly when set to block") {
                subject.relationship = RelationshipPriority.Block
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beTrue())
            }

            it("sets button state properly when set to friend") {
                subject.relationship = RelationshipPriority.Friend
                expect(subject.friendButton.selected).to(beTrue())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets button state properly when set to noise") {
                subject.relationship = RelationshipPriority.Noise
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beTrue())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets button state properly when set to anything else") {
                for relationship in [RelationshipPriority.Inactive, RelationshipPriority.None, RelationshipPriority.Null, RelationshipPriority.Me] {
                    subject.relationship = relationship
                    expect(subject.friendButton.selected).to(beFalse())
                    expect(subject.noiseButton.selected).to(beFalse())
                    expect(subject.blockButton!.selected).to(beFalse())
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

            context("with successful request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                describe("@friendButton") {
                    it("not selected") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Friend))
                    }

                    it("selected") {
                        subject.relationship = RelationshipPriority.Friend
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }
                }

                describe("@noiseButton") {
                    it("not selected") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Noise))
                    }

                    it("selected") {
                        subject.relationship = RelationshipPriority.Noise
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }
                }

                describe("@blockButton") {
                    it("not selected block") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
                    }

                    it("not selected mute") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
                    }

                    it("selected block") {
                        subject.relationship = RelationshipPriority.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected mute") {
                        subject.relationship = RelationshipPriority.Mute
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
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

                describe("@friendButton") {
                    it("not selected") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected") {
                        subject.relationship = RelationshipPriority.Friend
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Friend))
                    }
                }

                describe("@noiseButton") {
                    it("not selected") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected") {
                        subject.relationship = RelationshipPriority.Noise
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Noise))
                    }
                }

                describe("@blockButton") {
                    it("not selected block") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("not selected mute") {
                        subject.relationship = RelationshipPriority.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected block") {
                        subject.relationship = RelationshipPriority.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Block))
                    }

                    it("selected mute") {
                        subject.relationship = RelationshipPriority.Mute
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as! BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(RelationshipPriority.Mute))
                    }
                }
            }
        }
    }
}
