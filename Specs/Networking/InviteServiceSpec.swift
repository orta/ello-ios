//
//  InviteServiceSpec.swift
//  Ello
//
//  Created by Sean on 2/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Moya
import Nimble

class InviteServiceSpec: QuickSpec {
    override func spec() {
        describe("-invite:success:failure:") {

            var subject = InviteService()

            it("succeeds") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                var loadedSuccessfully = false
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                }, failure: nil)

                expect(loadedSuccessfully) == true
            }

            it("fails") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                var loadedSuccessfully = true
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) -> () in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }

        describe("-find:success:failure:") {

            var subject = InviteService()

            it("succeeds") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                var loadedSuccessfully = false
                var expectedUsers = [User]()
                subject.find(["contacts": ["1":["blah"], "2":["blah"]]], success: {
                    users in
                    expectedUsers = users
                }, failure: nil)

                expect(countElements(expectedUsers)) == 3
            }

            it("fails") {
                ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                var loadedSuccessfully = true

                subject.find(["contacts": ["1":["blah"], "2":["blah"]]], success: {
                    users in
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) -> () in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }
    }
}
