//
//  RelationshipServiceSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class RelationshipServiceSpec: QuickSpec {
    override func spec() {
        describe("-updateRelationship") {

            let subject = RelationshipService()

            it("succeeds") {
                var loadedSuccessfully = false
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.Following,
                    success: {
                        (data, responseConfig) in
                        loadedSuccessfully = true
                    },
                    failure: { _ in }
                )
                expect(loadedSuccessfully).to(beTrue())
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true
                subject.updateRelationship(currentUserId: "", userId: "42", relationshipPriority: RelationshipPriority.Following,
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
