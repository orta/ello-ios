//
//  ElloProviderSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/4/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Moya
import Nimble

@objc class TestObserver {
    var handled = false
    var object:AnyObject?

    func handleNotification(note:NSNotification) {
        handled = true
        object = note.object
    }
}

class ElloProviderSpec: QuickSpec {
    override func spec() {
        describe("error responses") {
            describe("with stubbed responses") {
                describe("a provider", {
                    var provider: MoyaProvider<ElloAPI>!
                    beforeEach {
                        provider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                    }

                    context("401", {

                        it("posts a notification with a status of 401", {

                            ElloProvider.errorStatusCode = .Status401

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            let testObserver = TestObserver()

                           NSNotificationCenter.defaultCenter().addObserver(testObserver, selector: "handleNotification:", name: "ElloProviderNotification401", object: nil)

                            let endpoint: ElloAPI = .FriendStream
                            provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, mappableType: Activity.self, success: { (data) -> () in
                                loadedJSONAbles = data as? [JSONAble]
                                }, failure: { (error, statusCode) -> () in
                                    loadedError = error
                                    loadedStatusCode = statusCode
                            })

                            expect(testObserver.handled) == true
                            expect(loadedJSONAbles).to(beNil())
                            expect(loadedStatusCode).to(beNil())
                            expect(loadedError).to(beNil())

                            let systemError = testObserver.object as NSError
                            let elloNetworkError = systemError.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError
                            
                            expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                            expect(elloNetworkError.error) == "unauthenticated"
                            expect(elloNetworkError.errorDescription) == "You are not authenticated for this request."
                            NSNotificationCenter.defaultCenter().removeObserver(testObserver)
                        })

                    })

                    context("403", {
                        itBehavesLike("network error") { ["provider":provider, "error":"unauthorized", "errorDescription":"You do not have access to the requested resource.", "statusCode":403]}
                    })

                    context("404", {
                        itBehavesLike("network error") { ["provider":provider, "error":"not_found", "errorDescription":"The requested resource could not be found.", "statusCode":404]}
                    })

                    context("410", {

                        it("posts a notification with a status of 410", {

                            ElloProvider.errorStatusCode = .Status410

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            let testObserver = TestObserver()

                            NSNotificationCenter.defaultCenter().addObserver(testObserver, selector: "handleNotification:", name: "ElloProviderNotification410", object: nil)

                            let endpoint: ElloAPI = .FriendStream
                            provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, mappableType: Activity.self, success: { (data) -> () in
                                loadedJSONAbles = data as? [JSONAble]
                                }, failure: { (error, statusCode) -> () in
                                    loadedError = error
                                    loadedStatusCode = statusCode
                            })

                            expect(testObserver.handled) == true
                            expect(loadedJSONAbles).to(beNil())
                            expect(loadedStatusCode).to(beNil())
                            expect(loadedError).to(beNil())

                            let systemError = testObserver.object as NSError
                            let elloNetworkError = systemError.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError

                            expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                            expect(elloNetworkError.error) == "invalid_version"
                            expect(elloNetworkError.errorDescription) == "The requested API version no longer exists."
                            NSNotificationCenter.defaultCenter().removeObserver(testObserver)
                        })
                        
                    })

                    context("420", {
                        itBehavesLike("network error") { ["provider":provider, "error":"rate_limited", "errorDescription":"The request could not be handled due to rate limiting.", "statusCode":420]}
                    })

                    context("422", {
                        itBehavesLike("network error") { ["provider":provider, "error":"invalid_resource", "errors" : ["name" : ["can't be blank"]], "errorDescription":"The current resource was invalid.", "messages" : ["Name can't be blank"], "statusCode":422]}
                    })

                    context("500", {
                        itBehavesLike("network error") { ["provider":provider, "error":"server_error", "errorDescription":"You have broken it, and have been blacklisted from using the API.", "statusCode":500]}
                    })

                    context("502", {
                        itBehavesLike("network error") { ["provider":provider, "error":"timeout", "errorDescription":"The service timed out. Try again?", "statusCode":502]}
                    })

                    context("503", {
                        itBehavesLike("network error") { ["provider":provider, "error":"unavailable", "errorDescription":"We're undergoing maintenance right now, but will be back online in about 2 minutes.", "statusCode":503]}
                    })
                })
            }
            
        }
    }
}

class NetworkErrorSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("network error") { (sharedExampleContext: SharedExampleContext) in
            it("Calls failure with an error and statusCode", {

                let provider: MoyaProvider<ElloAPI>! = sharedExampleContext()["provider"] as MoyaProvider<ElloAPI>
                let expectedError = sharedExampleContext()["error"] as String
                let expectedErrorDescription = sharedExampleContext()["errorDescription"] as String
                let expectedStatusCode = sharedExampleContext()["statusCode"] as Int
                ElloProvider.errorStatusCode = ElloProvider.ErrorStatusCode(rawValue: expectedStatusCode)!

                // optional values for 422
                let expectedErrors:[String:[String]]? = sharedExampleContext()["errors"] as? [String:[String]]
                let expectedMessages:[String]? = sharedExampleContext()["messages"] as? [String]


                var loadedJSONAbles:[JSONAble]?
                var loadedStatusCode:Int?
                var loadedError:NSError?

                let endpoint: ElloAPI = .FriendStream
                provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, mappableType: Activity.self, success: { (data) -> () in
                    loadedJSONAbles = data as? [JSONAble]
                    }, failure: { (error, statusCode) -> () in
                        loadedError = error
                        loadedStatusCode = statusCode
                })

                expect(loadedJSONAbles).to(beNil())
                expect(loadedStatusCode!) == expectedStatusCode
                expect(loadedError!).notTo(beNil())

                let elloNetworkError = loadedError!.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError

                expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                expect(elloNetworkError.error) == expectedError
                expect(elloNetworkError.errorDescription) == expectedErrorDescription

                if let expectedMessages = expectedMessages {
                    for (index, message) in enumerate(elloNetworkError.messages!) {
                        expect(message) == expectedMessages[index]
                    }
                }

                if let expectedErrors = expectedErrors {
                    for (errorFieldKey:String, errorArray:[String]) in elloNetworkError.errors! {
                        let expectedArray = expectedErrors[errorFieldKey]!
                        for (fieldIndex, error) in enumerate(errorArray) {
                            expect(expectedArray).to(contain(error))
                        }
                        expect(expectedErrors[errorFieldKey]).toNot(beNil())
                    }
                }
                
            })
        }
    }
}
