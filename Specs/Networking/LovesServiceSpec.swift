//
//  LovesServiceSpec.swift
//  Ello
//
//  Created by Sean on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Moya
import Nimble


class LovesServiceSpec: QuickSpec {
    override func spec() {

        describe("LovesService") {

            var subject = LovesService()

            describe("loadLovesForUser(_:streamKind:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successPosts: [Post]?
                        var failedCalled = false
                        subject.loadLovesForUser("fake-user-id",
                            streamKind: nil,
                            success: { (posts, responseConfig) in
                                successPosts = posts
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successPosts).notTo(beNil())
                        expect(failedCalled).to(beFalse())
                    }
                }

                context("failure") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    afterEach {
                        ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                    }

                    it("fails") {
                        var successPosts: [Post]?
                        var failedCalled = false
                        subject.loadLovesForUser("fake-user-id",
                            streamKind: nil,
                            success: { (posts, responseConfig) in
                                successPosts = posts
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successPosts).to(beNil())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }
        }
    }
}
