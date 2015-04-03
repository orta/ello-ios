//
//  BlockUserModalViewControllerSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class BlockUserModalViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Friend) {
            relationship in
        }
        let relationshipController = RelationshipController(presentingController: UIViewController())


        describe("initialization") {

            beforeEach {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Friend) {
                    relationship in
                }
                subject.loadView()
                subject.viewDidLoad()
            }

            it("sets IBOutlets") {
                expect(subject.backgroundButton).notTo(beNil())
                expect(subject.modalView).notTo(beNil())
                expect(subject.closeButton).notTo(beNil())
                expect(subject.titleLabel).notTo(beNil())
                expect(subject.muteButton).notTo(beNil())
                expect(subject.muteLabel).notTo(beNil())
                expect(subject.blockButton).notTo(beNil())
                expect(subject.blockLabel).notTo(beNil())
            }

            it("sets its transition properties") {
                expect(subject.modalPresentationStyle).to(equal(UIModalPresentationStyle.Custom))
                expect(subject.modalTransitionStyle).to(equal(UIModalTransitionStyle.CrossDissolve))
            }

            it("can be instantiated from storyboard") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a BlockUserModalViewController") {
                expect(subject).to(beAKindOf(BlockUserModalViewController.self))
            }
        }

        describe("@titleText") {
            it("is correct when relationship is mute") {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Mute) {
                    relationship in
                }
                expect(subject.titleText).to(equal("Would you like to \runmute or block @archer?"))
            }

            it("is correct when relationship is block") {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Block) {
                    relationship in
                }
                expect(subject.titleText).to(equal("Would you like to \rmute or unblock @archer?"))
            }

            it("is correct when relationship is not block or mute") {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Friend) {
                    relationship in
                }
                expect(subject.titleText).to(equal("Would you like to \rmute or block @archer?"))
            }
        }

        describe("@muteText") {
            it("is correct") {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Mute) {
                    relationship in
                }
                expect(subject.muteText).to(equal("@archer will not be able to comment on your posts. If @archer mentions you, you will not be notified."))
            }
        }

        describe("@blockText") {
            it("is correct") {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Mute) {
                    relationship in
                }
                expect(subject.blockText).to(equal("@archer will not be able to follow you or view your profile, posts or find you in search."))
            }
        }

        describe("@relationship") {

            beforeEach {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Mute) {
                    relationship in
                }
                subject.loadView()
                subject.viewDidLoad()
            }

            it("sets state properly when initialized with mute") {
                expect(subject.muteButton!.selected).to(beTrue())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets state properly when set to friend") {
                subject.relationship = Relationship.Friend
                expect(subject.muteButton!.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beFalse())
            }

            it("sets state properly when set to block") {
                subject.relationship = Relationship.Block
                expect(subject.muteButton!.selected).to(beFalse())
                expect(subject.blockButton!.selected).to(beTrue())
            }
        }

        describe("button targets") {

            beforeEach {
                subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationship: Relationship.Friend) {
                    relationship in
                }
                subject.loadView()
                subject.viewDidLoad()
                subject.relationshipDelegate = relationshipController
            }

            context("with successful request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                describe("@muteButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Friend
                        subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Mute))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Mute
                        subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }
                }

                describe("@blockButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Friend
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Block))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Inactive))
                    }
                }
            }

            context("with failed request") {

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                describe("@muteButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Friend
                        subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Friend))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Mute
                        subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Mute))
                    }
                }

                describe("@blockButton") {
                    it("not selected") {
                        subject.relationship = Relationship.Friend
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Friend))
                    }

                    it("selected") {
                        subject.relationship = Relationship.Block
                        subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(subject.relationship).to(equal(Relationship.Block))
                    }
                }
            }
        }
    }
}
