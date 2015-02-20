//
//  RelationshipViewSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class RelationshipViewSpec: QuickSpec {
    override func spec() {

        let subject = RelationshipView(coder: NSKeyedUnarchiver(forReadingWithData: NSData()))
        var presentingController = UIViewController()
        var keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        keyWindow.makeKeyAndVisible()
        keyWindow.rootViewController = presentingController
        presentingController.loadView()
        presentingController.viewDidLoad()
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
                subject.relationship = Relationship.Mute
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beTrue())
            }

            it("sets button state properly when set to block") {
                subject.relationship = Relationship.Block
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beTrue())
            }

            it("sets button state properly when set to friend") {
                subject.relationship = Relationship.Friend
                expect(subject.friendButton.selected).to(beTrue())
                expect(subject.noiseButton.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets button state properly when set to noise") {
                subject.relationship = Relationship.Noise
                expect(subject.friendButton.selected).to(beFalse())
                expect(subject.noiseButton.selected).to(beTrue())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets button state properly when set to anything else") {
                for relationship in [Relationship.Inactive, Relationship.None, Relationship.Null, Relationship.Me] {
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
                keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                keyWindow.makeKeyAndVisible()
                keyWindow.rootViewController = presentingController
                presentingController.loadView()
                presentingController.viewDidLoad()
                relationshipController = RelationshipController(presentingController: presentingController)
                subject.relationshipDelegate = relationshipController
            }

            context("with successful request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                describe("@friendButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Inactive
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Friend))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Friend
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }
                }

                describe("@noiseButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Inactive
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Noise))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Noise
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }
                }

                describe("@blockButton") {
                    it("not selected block") {
                        subject.relationship = Relationship.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Block))
                    }

                    it("not selected mute") {
                        subject.relationship = Relationship.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Mute))
                    }

                    it("selected block") {
                        subject.relationship = Relationship.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                    it("selected mute") {
                        subject.relationship = Relationship.Mute
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                }
            }

            context("with failed request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                describe("@friendButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Inactive
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Friend
                        subject.friendButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Friend))
                    }
                }

                describe("@noiseButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Inactive
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Noise
                        subject.noiseButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Noise))
                    }
                }

                describe("@blockButton") {
                    it("not selected block") {
                        subject.relationship = Relationship.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                    it("not selected mute") {
                        subject.relationship = Relationship.Inactive
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }

                    it("selected block") {
                        subject.relationship = Relationship.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Block))
                    }

                    it("selected mute") {
                        subject.relationship = Relationship.Mute
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        let presentedVC = relationshipController.presentingController.presentedViewController as BlockUserModalViewController
                        presentedVC.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Mute))
                    }
                }
            }
        }
    }
}
