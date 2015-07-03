//
//  AutoCompleteServiceSpec.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Moya
import Nimble


class AutoCompleteServiceSpec: QuickSpec {
    override func spec() {

        describe("AutoCompleteService") {

            var subject = AutoCompleteService()

            describe("loadResults(#terms:type:success:failure)") {

                context("username search") {

                    context("success") {

                        it("succeeds") {
                            var successCalled = false
                            var failedCalled = false
                            var loadedResults: [AutoCompleteResult]?
                            subject.loadResults("doesn't matter",
                                type: .Username,
                                success: { (results, responseConfig) in
                                    successCalled = true
                                    loadedResults = results
                                }, failure: { (_, _) in
                                    failedCalled = true
                                }
                            )

                            expect(successCalled) == true
                            expect(failedCalled) == false
                            expect(count(loadedResults!)) == 3
                            expect(loadedResults?[1].name) == "lanakane"
                            expect(loadedResults?[1].url!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/55/ello-small-aaca0f5e.png"
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
                            subject.loadResults("doesn't matter",
                                type: .Username,
                                success: { (results, responseConfig) in
                                    successCalled = true
                                }, failure: { (_, _) in
                                    failedCalled = true
                                }
                            )

                            expect(successCalled) == false
                            expect(failedCalled) == true
                        }
                    }
                }

                context("emoji search") {

                    context("success") {

                        it("succeeds") {
                            var successCalled = false
                            var failedCalled = false
                            var loadedResults: [AutoCompleteResult]?
                            subject.loadResults("doesn't matter",
                                type: .Emoji,
                                success: { (results, responseConfig) in
                                    successCalled = true
                                    loadedResults = results
                                }, failure: { (_, _) in
                                    failedCalled = true
                                }
                            )

                            expect(successCalled) == true
                            expect(failedCalled) == false
                            expect(count(loadedResults!)) == 3
                            expect(loadedResults?[1].name) == "lanakane"
                            expect(loadedResults?[1].url!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/55/ello-small-aaca0f5e.png"
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
                            subject.loadResults("doesn't matter",
                                type: .Emoji,
                                success: { (results, responseConfig) in
                                    successCalled = true
                                }, failure: { (_, _) in
                                    failedCalled = true
                                }
                            )

                            expect(successCalled) == false
                            expect(failedCalled) == true
                        }
                    }
                }

            }
        }
    }
}
