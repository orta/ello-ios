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
import Alamofire


class TestObserver {
    var handled = false
    var object:AnyObject?

    func handleNotification(note:NSNotification) {
        handled = true
        object = note.object
    }
}


class ElloProviderSpec: QuickSpec {
    override func spec() {

        afterEach {
            AppSetup.sharedState.isSimulator = nil
        }

        describe("serverTrustPolicies") {

            it("has one when not in the simulator") {
                AppSetup.sharedState.isSimulator = false
                // TODO: figure out how to mock UIDevice.currentDevice().model
                expect(ElloProvider.serverTrustPolicies["ello.co"]).notTo(beNil())
            }

            it("has zero when in the simulator") {
                AppSetup.sharedState.isSimulator = true
                expect(ElloProvider.serverTrustPolicies["ello.co"]).to(beNil())
            }

        }

        describe("SSL Pinning") {

            it("has a custom Alamofire.Manager") {
                let defaultManager = Alamofire.Manager.sharedInstance
                let elloManager = ElloProvider.sharedProvider.manager

                expect(elloManager).notTo(beIdenticalTo(defaultManager))
            }

            it("includes 2 ssl certificates in the app") {
                AppSetup.sharedState.isSimulator = false
                let policy = ElloProvider.serverTrustPolicies["ello.co"]!
                var doesValidatesChain = false
                var doesValidateHost = false
                var keys = [SecKey]()
                switch policy {
                case let .PinPublicKeys(publicKeys, validateCertificateChain, validateHost):
                    doesValidatesChain = validateCertificateChain
                    doesValidateHost = validateHost
                    keys = publicKeys
                default: break
                }

                expect(doesValidatesChain) == true
                expect(doesValidateHost) == true
                let numberOfCerts = 2
                // Charles installs a cert, and we should allow that, so test
                // for numberOfCerts OR numberOfCerts + 1
                expect(keys.count == numberOfCerts || keys.count == numberOfCerts + 1) == true
            }
        }

        describe("parameterEncoding") {
            it("is .URL for most things") {
                let endpoint = ElloProvider.endpointClosure(ElloAPI.AmazonCredentials)
                expect(endpoint.parameterEncoding).to(equal(Moya.ParameterEncoding.URL))
            }
            it("is .JSON for CreatePost") {
                let endpoint = ElloProvider.endpointClosure(ElloAPI.CreatePost(body: [:]))
                expect(endpoint.parameterEncoding).to(equal(Moya.ParameterEncoding.JSON))
            }
            it("is .JSON for CreateComment") {
                let endpoint = ElloProvider.endpointClosure(ElloAPI.CreateComment(parentPostId: "foo", body: [:]))
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

                            ElloProvider_Specs.errorStatusCode = .Status401_Unauthorized

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            var object: NSError?
                            var handled = false

                            let testObserver = NotificationObserver(notification: ErrorStatusCode.Status401_Unauthorized.notification) { error in
                                object = error
                                handled = true
                            }

                            let endpoint: ElloAPI = .FriendStream
                            ElloProvider.shared.elloRequest(endpoint, success: { (data, responseConfig) in
                                loadedJSONAbles = data as? [JSONAble]
                            }, failure: { (error, statusCode) in
                                loadedError = error
                                loadedStatusCode = statusCode
                            })

                            expect(handled) == true
                            expect(loadedJSONAbles).to(beNil())
                            expect(loadedStatusCode).to(beNil())
                            expect(loadedError).to(beNil())
                            expect(object).notTo(beNil())

                            if let elloNetworkError = object?.userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                                expect(elloNetworkError.status) == "401"
                                expect(elloNetworkError.code) == ElloNetworkError.CodeType.unauthenticated
                                expect(elloNetworkError.detail).to(beNil())
                            }
                            else {
                                fail("error is not an elloNetworkError")
                            }

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

                            ElloProvider_Specs.errorStatusCode = .Status410

                            var loadedJSONAbles:[JSONAble]?
                            var loadedStatusCode:Int?
                            var loadedError:NSError?
                            var handled = false
                            var object: NSError?
                            let testObserver = NotificationObserver(notification: ErrorStatusCode.Status410.notification) { error in
                                handled = true
                                object = error
                            }

                            let endpoint: ElloAPI = .FriendStream
                            ElloProvider.shared.elloRequest(endpoint,
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

                            if let elloNetworkError = object?.userInfo[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                                expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                                expect(elloNetworkError.status) == "410"
                                expect(elloNetworkError.title) == "The requested API version no longer exists."
                                expect(elloNetworkError.code) == ElloNetworkError.CodeType.invalidVersion
                                expect(elloNetworkError.detail).to(beNil())
                            }
                            else {
                                fail("error is not an elloNetworkError")
                            }
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
                ElloProvider_Specs.errorStatusCode = ErrorStatusCode(rawValue: expectedStatusCode)!

                // optional values for 422
                let expectedAttrs:[String:[String]]? = sharedExampleContext()["attrs"] as? [String:[String]]
                let expectedMessages:[String]? = sharedExampleContext()["messages"] as? [String]

                var loadedJSONAbles:[JSONAble]?
                var loadedStatusCode:Int?
                var loadedError:NSError?

                let endpoint: ElloAPI = .FriendStream
                ElloProvider.shared.elloRequest(endpoint,
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
                let elloNetworkError = loadedError!.userInfo[NSLocalizedFailureReasonErrorKey] as! ElloNetworkError

                expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                expect(elloNetworkError.status!) == expectedStatus
                expect(elloNetworkError.title) == expectedTitle

                if let expectedDetail = expectedDetail {
                    expect(elloNetworkError.detail) == expectedDetail
                }

                expect(elloNetworkError.code) == expectedCodeType

                if let expectedMessages = expectedMessages {
                    for (index, message) in elloNetworkError.messages!.enumerate() {
                        expect(message) == expectedMessages[index]
                    }
                }

                if let expectedAttrs = expectedAttrs {
                    for (errorFieldKey, errorArray): (String, [String]) in elloNetworkError.attrs! {
                        let expectedArray = expectedAttrs[errorFieldKey]!
                        for (_, error) in errorArray.enumerate() {
                            expect(expectedArray).to(contain(error))
                        }
                        expect(expectedAttrs[errorFieldKey]).toNot(beNil())
                    }
                }
            }
        }
    }
}
