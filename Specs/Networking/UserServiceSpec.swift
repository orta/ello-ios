//
//  UserServiceSpec.swift
//  Ello
//
//  Created by Sean on 4/8/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import Ello
import Quick
import Moya
import Nimble


class UserServiceSpec: QuickSpec {
    override func spec() {
        var subject = UserService()

        beforeEach {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterEach {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("-join") {

            context("success") {

                it("Calls success with a User") {
                    var loadedUser: User?

                    subject.join(email: "fake@example.com",
                        username: "fake-username",
                        password: "fake-password",
                        invitationCode: .None,
                        success: {
                            (user, responseConfig) in
                            loadedUser = user
                        }, failure: .None)

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.userId) == "1"
                    expect(loadedUser!.email) == "sterling@isisagency.com"
                    expect(loadedUser!.username) == "archer"
                }
            }

            xcontext("failure") {}

        }
    }
}
