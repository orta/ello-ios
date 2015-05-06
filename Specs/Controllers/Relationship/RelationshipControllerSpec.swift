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
            var presentingController = UIViewController()
            self.showController(presentingController)
            subject = RelationshipController(presentingController: presentingController)

        })

        context("RelationshipDelegate") {

            describe("-launchBlockModal:relationship:complete:") {

                it("succeeds") {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                    var expectedStatus = RelationshipRequestStatus.Failure

                    subject.relationshipTapped("test-user-id", relationship: RelationshipPriority.Friend) {
                        (status, relationship) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Success))
                }

                it("fails") {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)

                    var expectedStatus = RelationshipRequestStatus.Success

                    subject.relationshipTapped("test-user-id", relationship: RelationshipPriority.Friend) {
                        (status, relationship) in
                        expectedStatus = status
                    }
                    expect(expectedStatus).to(equal(RelationshipRequestStatus.Failure))
                }
            }

            describe("-launchBlockModal:userAtName:relationship:changeClosure:") {

                it("launches the block user modal view controller") {
                    subject.launchBlockModal("user-id", userAtName: "@666", relationship: RelationshipPriority.Friend) {
                        relationship in
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
