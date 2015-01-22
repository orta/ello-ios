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
        
        var provider: MoyaProvider<ElloAPI>!
        beforeEach {
            provider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
        }
        
        describe("-mapToObject:propertyName:") {
            
            it("maps the correct type") {
                let testDict = ["users":["name":"Sean", "id":"testid"]]
            }
        }
        
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
                            provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, propertyName: MappingType.Prop.Activities, success: { (data) -> () in
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
                            expect(elloNetworkError.status) == "401"
                            expect(elloNetworkError.title) == "You are not authenticated for this request."
                            expect(elloNetworkError.code) == ElloNetworkError.CodeType.unauthenticated
                            expect(elloNetworkError.detail).to(beNil())

                            NSNotificationCenter.defaultCenter().removeObserver(testObserver)
                        })

                    })

                    context("403", {
                        itBehavesLike("network error") { ["provider":provider, "status":"403", "title":"You do not have access to the requested resource.", "statusCode":403, "code" : ElloNetworkError.CodeType.unauthorized.rawValue]}
                    })

                    context("404", {
                        itBehavesLike("network error") { ["provider":provider, "status":"404", "title":"The requested resource could not be found.", "statusCode":404, "code" : ElloNetworkError.CodeType.notFound.rawValue]}
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
                            provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, propertyName: MappingType.Prop.Activities, success: { (data) -> () in
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
                            expect(elloNetworkError.status) == "410"
                            expect(elloNetworkError.title) == "The requested API version no longer exists."
                            expect(elloNetworkError.code) == ElloNetworkError.CodeType.invalidVersion
                            expect(elloNetworkError.detail).to(beNil())
                            NSNotificationCenter.defaultCenter().removeObserver(testObserver)
                        })
                        
                    })

                    context("420", {
                        itBehavesLike("network error") { ["provider":provider, "status":"420", "title":"The request could not be handled due to rate limiting.", "statusCode":420, "code" : ElloNetworkError.CodeType.rateLimited.rawValue]}
                    })

                    context("422", {
                        itBehavesLike("network error") { ["provider":provider, "status":"422", "attrs" : ["name" : ["can't be blank"]], "title":"The current resource was invalid.", "messages" : ["Name can't be blank"], "statusCode":422, "code" : ElloNetworkError.CodeType.invalidResource.rawValue]}
                    })

                    context("500", {
                        itBehavesLike("network error") { ["provider":provider, "status":"500", "title":"An unknown error has occurred.", "statusCode":500, "code" : ElloNetworkError.CodeType.serverError.rawValue, "detail" : "You have broken it, and have been blacklisted from using the API."]}
                    })

                    context("502", {
                        itBehavesLike("network error") { ["provider":provider, "status":"502", "title":"The service timed out. Try again?", "statusCode":502, "code" : ElloNetworkError.CodeType.timeout.rawValue]}
                    })

                    context("503", {
                        itBehavesLike("network error") { ["provider":provider, "status" : "503", "title":"The service is unavailable. Try back shortly.", "detail":"Oh snap, the service is down while we work on it.", "statusCode":503, "code" : ElloNetworkError.CodeType.unavailable.rawValue]}
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
                let expectedTitle = sharedExampleContext()["title"] as String
                let expectedDetail = sharedExampleContext()["detail"] as? String
                let expectedStatus = sharedExampleContext()["status"] as String
                let expectedStatusCode = sharedExampleContext()["statusCode"] as Int
                let expectedCode = sharedExampleContext()["code"] as String
                let expectedCodeType = ElloNetworkError.CodeType(rawValue: expectedCode)!
                ElloProvider.errorStatusCode = ElloProvider.ErrorStatusCode(rawValue: expectedStatusCode)!

                // optional values for 422
                let expectedAttrs:[String:[String]]? = sharedExampleContext()["attrs"] as? [String:[String]]
                let expectedMessages:[String]? = sharedExampleContext()["messages"] as? [String]

                var loadedJSONAbles:[JSONAble]?
                var loadedStatusCode:Int?
                var loadedError:NSError?

                let endpoint: ElloAPI = .FriendStream
                provider.elloRequest(endpoint, method: Moya.Method.GET, parameters: endpoint.defaultParameters, propertyName: MappingType.Prop.Activities, success: { (data) -> () in
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
                
            })
        }
    }
}
