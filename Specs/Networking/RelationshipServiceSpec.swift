//
//  RelationshipServiceSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import Quick
import Moya
import Nimble

class RelationshipServiceSpec: QuickSpec {
    override func spec() {
        describe("-updateRelationship") {

            var subject = RelationshipService()

            it("succeeds") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                var loadedSuccessfully = false
                subject.updateRelationship(ElloAPI.Relationship(userId: "42", relationship: Relationship.Friend.rawValue),
                    success: {
                        (data, responseConfig) in
                        loadedSuccessfully = true
                    },
                    failure: nil
                )
                expect(loadedSuccessfully).to(beTrue())
            }

            it("fails") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                var loadedSuccessfully = true
                subject.updateRelationship(ElloAPI.Relationship(userId: "42", relationship: Relationship.Friend.rawValue),
                    success: {
                        (data, responseConfig) in
                        loadedSuccessfully = true
                    },
                    failure: {
                        (error, statusCode) in
                        loadedSuccessfully = false
                    }
                )
                expect(loadedSuccessfully).to(beFalse())
            }

        }
    }
}

