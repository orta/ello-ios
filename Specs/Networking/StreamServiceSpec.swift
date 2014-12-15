//
//  StreamServiceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Quick
import Moya
import Nimble

class StreamServiceSpec: QuickSpec {
    override func spec() {
        describe("-loadFriendStream", {

            var streamService = StreamService()

            context("success", {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                it("Calls success with an array of Activity objects", {
                    var loadedActivities:[Activity]?

                    streamService.loadFriendStream({ (activities) -> () in
                        loadedActivities = activities
                    }, failure: nil)

                    expect(countElements(loadedActivities!)) == 25
                    expect(loadedActivities![2].activityId) == 11837
                })
            })

            context("failure", {

                // smoke test a few failure status codes, the whole lot is tested in ElloProviderSpec

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                context("404", {

                    beforeEach {
                        ElloProvider.errorStatusCode = .Status404
                    }

                    it("Calls failure with an error and statusCode", {

                        var loadedActivities:[Activity]?
                        var loadedStatusCode:Int?
                        var loadedError:NSError?

                        streamService.loadFriendStream({ (activities) -> () in
                            loadedActivities = activities
                        }, failure: { (error, statusCode) -> () in
                                loadedError = error
                                loadedStatusCode = statusCode
                        })

                        expect(loadedActivities).to(beNil())
                        expect(loadedStatusCode!) == 404
                        expect(loadedError!).notTo(beNil())

                        let elloNetworkError = loadedError!.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError

                        expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                        expect(elloNetworkError.error) == "not_found"
                        expect(elloNetworkError.errorDescription) == "The requested resource could not be found."

                    })
                    
                })

            })

        })
    }
}
