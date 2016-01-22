//
//  ReauthenticationSpec.swift
//  Ello
//
//  Created by Colin Gray on 1/19/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class ReauthenticationSpec: QuickSpec {
    override func spec() {
        describe("Reauthentication") {
            it("should reauth with refresh token after 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .FriendStream, response: .NetworkResponse(401, NSData())),
                    ])
                var succeeded = false
                var failed = false
                var invalidToken = false
                ElloProvider.shared.elloRequest(.FriendStream, success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                }, invalidToken: { _ in
                    invalidToken = true
                })
                expect(AuthToken.sharedKeychain.authToken) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(succeeded) == true
                expect(failed) == false
                expect(invalidToken) == false
            }
            it("should reauth with user/pass after 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .FriendStream, response: .NetworkResponse(401, NSData())),
                    RecordedResponse(endpoint: .ReAuth(token: ""), response: .NetworkResponse(401, NSData())),
                    ])
                var succeeded = false
                var failed = false
                var invalidToken = false
                ElloProvider.shared.elloRequest(.FriendStream, success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                }, invalidToken: { _ in
                    invalidToken = true
                })
                expect(AuthToken.sharedKeychain.authToken) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(succeeded) == true
                expect(failed) == false
                expect(invalidToken) == false
            }
            it("should reauth with token after NetworkFailure") {
                let networkError = NSError.networkError("Failed to send request", code: ElloErrorCode.NetworkFailure)
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .FriendStream, response: .NetworkResponse(401, NSData())),
                    RecordedResponse(endpoint: .ReAuth(token: ""), response: .NetworkError(networkError)),
                    RecordedResponse(endpoint: .ReAuth(token: ""), response: .NetworkError(networkError)),
                    ])
                var succeeded = false
                var failed = false
                var invalidToken = false
                ElloProvider.shared.elloRequest(.FriendStream, success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                }, invalidToken: { _ in
                    invalidToken = true
                })
                expect(AuthToken.sharedKeychain.authToken) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(succeeded) == true
                expect(failed) == false
                expect(invalidToken) == false
            }
            it("should logout after failed reauth 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .FriendStream, response: .NetworkResponse(401, NSData())),
                    RecordedResponse(endpoint: .ReAuth(token: ""), response: .NetworkResponse(401, NSData())),
                    RecordedResponse(endpoint: .Auth(email: "", password: ""), response: .NetworkResponse(404, NSData())),
                    ])
                var succeeded = false
                var failed = false
                var invalidToken = false
                ElloProvider.shared.elloRequest(.FriendStream, success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                }, invalidToken: { _ in
                    invalidToken = true
                })
                expect(AuthToken.sharedKeychain.authToken).to(beNil())
                expect(succeeded) == false
                expect(failed) == false
                expect(invalidToken) == true
            }
        }
    }
}
