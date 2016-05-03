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
        describe("BlockUserModalViewController") {
            let currentUser: User = stub([:])
            var subject: BlockUserModalViewController!
            let relationshipController = RelationshipController(presentingController: UIViewController())
            relationshipController.currentUser = currentUser

            describe("initialization") {

                beforeEach {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Following) {
                        relationship in
                    }
                    subject.currentUser = currentUser
                    showController(subject)
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
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Mute) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    expect(subject.titleText).to(equal("Would you like to \nunmute or block @archer?"))
                }

                it("is correct when relationship is block") {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Block) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    expect(subject.titleText).to(equal("Would you like to \nmute or unblock @archer?"))
                }

                it("is correct when relationship is not block or mute") {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Following) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    expect(subject.titleText).to(equal("Would you like to \nmute or block @archer?"))
                }
            }

            describe("@muteText") {
                it("is correct") {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Mute) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    expect(subject.muteText).to(equal("@archer will not be able to comment on your posts. If @archer mentions you, you will not be notified."))
                }
            }

            describe("@blockText") {
                it("is correct") {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Mute) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    expect(subject.blockText).to(equal("@archer will not be able to follow you or view your profile, posts or find you in search."))
                }
            }

            describe("@relationship") {

                beforeEach {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Mute) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("sets state properly when initialized with mute") {
                    expect(subject.muteButton!.selected).to(beTrue())
                    expect(subject.blockButton!.selected).to(beFalse())
                }

                it("sets state properly when set to friend") {
                    subject.relationshipPriority = RelationshipPriority.Following
                    expect(subject.muteButton!.selected).to(beFalse())
                    expect(subject.blockButton!.selected).to(beFalse())
                }

                it("sets state properly when set to block") {
                    subject.relationshipPriority = RelationshipPriority.Block
                    expect(subject.muteButton!.selected).to(beFalse())
                    expect(subject.blockButton!.selected).to(beTrue())
                }
            }

            describe("button targets") {

                beforeEach {
                    subject = BlockUserModalViewController(userId: "666", userAtName: "@archer", relationshipPriority: RelationshipPriority.Following) {
                        _ in
                    }
                    subject.currentUser = currentUser
                    showController(subject)
                    subject.relationshipDelegate = relationshipController
                }

                context("with successful request") {

                    describe("@muteButton") {
                        it("not selected") {
                            subject.relationshipPriority = RelationshipPriority.Following
                            subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Mute))
                        }

                        it("selected") {
                            subject.relationshipPriority = RelationshipPriority.Mute
                            subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }
                    }

                    describe("@blockButton") {
                        it("not selected") {
                            subject.relationshipPriority = RelationshipPriority.Following
                            subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Block))
                        }

                        it("selected") {
                            subject.relationshipPriority = RelationshipPriority.Block
                            subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                        }
                    }
                }

                context("with failed request") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    describe("@muteButton") {
                        it("not selected") {
                            subject.relationshipPriority = RelationshipPriority.Following
                            subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Following))
                        }

                        it("selected") {
                            subject.relationshipPriority = RelationshipPriority.Mute
                            subject.muteButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Mute))
                        }
                    }

                    describe("@blockButton") {
                        it("not selected") {
                            subject.relationshipPriority = RelationshipPriority.Following
                            subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Following))
                        }

                        it("selected") {
                            subject.relationshipPriority = RelationshipPriority.Block
                            subject.blockButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                            expect(subject.relationshipPriority).to(equal(RelationshipPriority.Block))
                        }
                    }
                }
            }
        }
    }
}
