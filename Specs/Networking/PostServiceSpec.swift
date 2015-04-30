//
//  PostServiceSpec.swift
//  Ello
//
//  Created by Sean on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Moya
import Nimble


class PostServiceSpec: QuickSpec {
    override func spec() {
        describe("PostService") {

            var subject = PostService()

            beforeSuite {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
            }

            afterSuite {
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
            }

            describe("loadPost(_:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successPost: Post?
                        var failedCalled = false
                        subject.loadPost("fake-post-param",
                            streamKind: nil,
                            success: { (post, responseConfig) in
                                successPost = post
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successPost).notTo(beNil())
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
                        var successPost: Post?
                        var failedCalled = false
                        subject.loadPost("fake-post-param",
                            streamKind: nil,
                            success: { (post, responseConfig) in
                                successPost = post
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successPost).to(beNil())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

            describe("deletePost(_:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deletePost("fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: {
                                (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beTrue())
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
                        var successCalled = false
                        var failedCalled = false
                        subject.deletePost("fake-post-id",
                            success: {
                                successCalled = true
                            }, failure: {
                                (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beFalse())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

            describe("deleteComment(_:commentId:success:failure)") {

                context("success") {

                    it("succeeds") {
                        var successCalled = false
                        var failedCalled = false
                        subject.deleteComment("fake-post-id",
                            commentId: "fake-comment-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beTrue())
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
                        var successCalled = false
                        var failedCalled = false
                        subject.deleteComment("fake-post-id",
                            commentId: "fake-comment-id",
                            success: {
                                successCalled = true
                            }, failure: { (_, _) in
                                failedCalled = true
                            }
                        )

                        expect(successCalled).to(beFalse())
                        expect(failedCalled).to(beTrue())
                    }
                }
            }

        }
    }
}
