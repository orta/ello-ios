//
//  InviteServiceSpec.swift
//  Ello
//
//  Created by Sean on 2/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Moya
import Nimble


class InviteServiceSpec: QuickSpec {
    override func spec() {
        describe("-invite:success:failure:") {

            let subject = InviteService()

            it("succeeds") {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                var loadedSuccessfully = false
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                    }, failure: { _ in })

                expect(loadedSuccessfully) == true
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }

        describe("-find:success:failure:") {

            let subject = InviteService()

            it("succeeds") {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                var expectedUsers = [User]()
                subject.find(["1":["blah"], "2":["blah"]], currentUser: nil, success: {
                    users in
                    expectedUsers = users
                }, failure: { _ in })

                expect(expectedUsers.count) == 3
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true

                subject.find(["1":["blah"], "2":["blah"]], currentUser: nil, success: {
                    users in
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }
    }
}
