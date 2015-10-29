//
//  RelationshipControllerSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class RelationshipControllerSpec: QuickSpec {
    override func spec() {
        var subject = RelationshipController(presentingController: UIViewController())

        beforeEach({
            let presentingController = UIViewController()
            self.showController(presentingController)
            subject = RelationshipController(presentingController: presentingController)

        })

        context("RelationshipDelegate") {

            describe("-relationshipTapped:relationship:complete:") {
                // extensively tested in RelationshipControlSpec
            }

            describe("-updateRelationship:relationship:complete:") {

                it("succeeds") {
                    ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.endpointClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                    var expectedStatus = RelationshipRequestStatus.Failure

                    subject.updateRelationship("", userId: "test-user-id", relationshipPriority: RelationshipPriority.Following) {
                        (status, _) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Success))
                }

                it("fails") {
                    ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.errorEndpointsClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)

                    var expectedStatus = RelationshipRequestStatus.Success

                    subject.updateRelationship("", userId: "test-user-id", relationshipPriority: RelationshipPriority.Following) {
                        (status, _) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Failure))
                }
            }

            describe("-launchBlockModal:userAtName:relationship:changeClosure:") {

                it("launches the block user modal view controller") {
                    subject.launchBlockModal("user-id", userAtName: "@666", relationshipPriority: RelationshipPriority.Following) {
                        _ in
                    }
                    let presentedVC = subject.presentingController.presentedViewController as! BlockUserModalViewController
                    // TODO: figure this out
//                    expect(presentedVC.relationshipDelegate).to(beIdenticalTo(subject))
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController.self))
                }

            }

        }
    }
}
