 //
//  ElloProviderSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/4/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
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

        beforeEach {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterEach {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("parameterEncoding") {
            it("is .URL for most things") {
                let endpoint = ElloProvider.endpointsClosure(ElloAPI.AmazonCredentials, Moya.Method.GET, [:])
                expect(endpoint.parameterEncoding).to(equal(Moya.ParameterEncoding.URL))
            }
            it("is .JSON for CreatePost") {
                let endpoint = ElloProvider.endpointsClosure(ElloAPI.CreatePost(body: [:]), Moya.Method.GET, [:])
                expect(endpoint.parameterEncoding).to(equal(Moya.ParameterEncoding.JSON))
            }
            it("is .JSON for CreateComment") {
                let endpoint = ElloProvider.endpointsClosure(ElloAPI.CreateComment(parentPostId: "foo", body: [:]), Moya.Method.GET, [:])
                expect(endpoint.parameterEncoding).to(equal(Moya.ParameterEncoding.JSON))
            }
        }

        describe("error responses") {
            describe("with stubbed responses") {
                describe("a provider") {

                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    }

                    afterEach {
                        ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                    }

                    context("401") {

                        it("posts a notification with a status of 401") {

                            ElloProvider.errorStatusCode = .Status401

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            var handled = false
                            var object = NSError()

                            let testObserver = NotificationObserver(notification: ElloProvider.ErrorStatusCode.Status401.notification) { error in
                                handled = true
                                object = error
                            }

                            let endpoint: ElloAPI = .FriendStream
                            ElloProvider.elloRequest(endpoint, success: { (data, responseConfig) in
                                    loadedJSONAbles = data as? [JSONAble]
                                }, failure: { (error, statusCode) in
                                    loadedError = error
                                    loadedStatusCode = statusCode
                            })

                            expect(handled) == true
                            expect(loadedJSONAbles).to(beNil())
                            expect(loadedStatusCode).to(beNil())
                            expect(loadedError).to(beNil())

                            let elloNetworkError = object.userInfo![NSLocalizedFailureReasonErrorKey] as! ElloNetworkError

                            expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                            expect(elloNetworkError.status) == "401"
                            expect(elloNetworkError.title) == "You are not authenticated for this request."
                            expect(elloNetworkError.code) == ElloNetworkError.CodeType.unauthenticated
                            expect(elloNetworkError.detail).to(beNil())

                            testObserver.removeObserver()
                        }

                    }

                    context("403") {
                        itBehavesLike("network error") { ["status":"403", "title":"You do not have access to the requested resource.", "statusCode":403, "code" : ElloNetworkError.CodeType.unauthorized.rawValue]}
                    }

                    context("404") {
                        itBehavesLike("network error") { ["status":"404", "title":"The requested resource could not be found.", "statusCode":404, "code" : ElloNetworkError.CodeType.notFound.rawValue]}
                    }

                    context("410") {

                        it("posts a notification with a status of 410") {

                            ElloProvider.errorStatusCode = .Status410

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            var handled = false
                            var object = NSError()
                            let testObserver = NotificationObserver(notification: ElloProvider.ErrorStatusCode.Status410.notification) { error in
                                handled = true
                                object = error
                            }

                            let endpoint: ElloAPI = .FriendStream
                            ElloProvider.elloRequest(endpoint,
                                success: { (data, responseConfig) in
                                    loadedJSONAbles = data as? [JSONAble]
                                },
                                failure: { (error, statusCode) in
                                    loadedError = error
                                    loadedStatusCode = statusCode
                                }
                            )

                            expect(handled) == true
                            expect(loadedJSONAbles).to(beNil())
                            expect(loadedStatusCode).to(beNil())
                            expect(loadedError).to(beNil())

                            let elloNetworkError = object.userInfo![NSLocalizedFailureReasonErrorKey] as! ElloNetworkError

                            expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                            expect(elloNetworkError.status) == "410"
                            expect(elloNetworkError.title) == "The requested API version no longer exists."
                            expect(elloNetworkError.code) == ElloNetworkError.CodeType.invalidVersion
                            expect(elloNetworkError.detail).to(beNil())
                            testObserver.removeObserver()
                        }

                    }

                    context("420") {
                        itBehavesLike("network error") { ["status":"420", "title":"The request could not be handled due to rate limiting.", "statusCode":420, "code" : ElloNetworkError.CodeType.rateLimited.rawValue]}
                    }

                    context("422") {
                        itBehavesLike("network error") { ["status":"422", "attrs" : ["name" : ["can't be blank"]], "title":"The current resource was invalid.", "messages" : ["Name can't be blank"], "statusCode":422, "code" : ElloNetworkError.CodeType.invalidResource.rawValue]}
                    }

                    context("500") {
                        itBehavesLike("network error") { ["status":"500", "title":"An unknown error has occurred.", "statusCode":500, "code" : ElloNetworkError.CodeType.serverError.rawValue, "detail" : "You have broken it, and have been blacklisted from using the API."]}
                    }

                    context("502") {
                        itBehavesLike("network error") { ["status":"502", "title":"The service timed out. Try again?", "statusCode":502, "code" : ElloNetworkError.CodeType.timeout.rawValue]}
                    }

                    context("503") {
                        itBehavesLike("network error") { ["status" : "503", "title":"The service is unavailable. Try back shortly.", "detail":"Oh snap, the service is down while we work on it.", "statusCode":503, "code" : ElloNetworkError.CodeType.unavailable.rawValue]}
                    }
                }
            }

        }
    }
}

class NetworkErrorSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("network error") { (sharedExampleContext: SharedExampleContext) in
            it("Calls failure with an error and statusCode") {

                let expectedTitle = sharedExampleContext()["title"] as! String
                let expectedDetail = sharedExampleContext()["detail"] as? String
                let expectedStatus = sharedExampleContext()["status"] as! String
                let expectedStatusCode = sharedExampleContext()["statusCode"] as! Int
                let expectedCode = sharedExampleContext()["code"] as! String
                let expectedCodeType = ElloNetworkError.CodeType(rawValue: expectedCode)!
                ElloProvider.errorStatusCode = ElloProvider.ErrorStatusCode(rawValue: expectedStatusCode)!

                // optional values for 422
                let expectedAttrs:[String:[String]]? = sharedExampleContext()["attrs"] as? [String:[String]]
                let expectedMessages:[String]? = sharedExampleContext()["messages"] as? [String]

                var loadedJSONAbles:[JSONAble]?
                var loadedStatusCode:Int?
                var loadedError:NSError?

                let endpoint: ElloAPI = .FriendStream
                ElloProvider.elloRequest(endpoint,
                    success: { (data, responseConfig) in
                        loadedJSONAbles = data as? [JSONAble]
                    },
                    failure: { (error, statusCode) in
                        loadedError = error
                        loadedStatusCode = statusCode
                    }
                )

                expect(loadedJSONAbles).to(beNil())
                expect(loadedStatusCode!) == expectedStatusCode
                expect(loadedError!).notTo(beNil())
                let elloNetworkError = loadedError!.userInfo![NSLocalizedFailureReasonErrorKey] as! ElloNetworkError

                expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                expect(elloNetworkError.status!) == expectedStatus
                expect(elloNetworkError.title) == expectedTitle

                if let expectedDetail = expectedDetail {
                    expect(elloNetworkError.detail) == expectedDetail
                }

                expect(elloNetworkError.code) == expectedCodeType

                if let expectedMessages = expectedMessages {
                    for (index, message) in enumerate(elloNetworkError.messages!) {
                        expect(message) == expectedMessages[index]
                    }
                }

                if let expectedAttrs = expectedAttrs {
                    for (errorFieldKey:String, errorArray:[String]) in elloNetworkError.attrs! {
                        let expectedArray = expectedAttrs[errorFieldKey]!
                        for (fieldIndex, error) in enumerate(errorArray) {
                            expect(expectedArray).to(contain(error))
                        }
                        expect(expectedAttrs[errorFieldKey]).toNot(beNil())
                    }
                }
            }
        }
    }
}
