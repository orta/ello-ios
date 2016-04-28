//
//  AuthStateSpec.swift
//  Ello
//
//  Created by Colin Gray on 1/25/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class AuthStateSpec: QuickSpec {
    override func spec() {
        describe("AuthState") {
            describe("supports(AuthState)") {
                let noTokenReqd: [ElloAPI] = [.Auth(email: "", password: ""), .ReAuth(token: ""), .AnonymousCredentials]
                let anonymous: [ElloAPI] = [.Availability(content: [:]), .Join(email: "", username: "", password: "", invitationCode: nil)]
                let authdOnly: [ElloAPI] = [.AmazonCredentials, .AwesomePeopleStream, .NoiseStream, .CurrentUserStream, .UserStream(userParam: "")]
                let expectations: [(AuthState, supported: [ElloAPI], unsupported: [ElloAPI])] = [
                    (.NoToken, supported: noTokenReqd, unsupported: authdOnly),
                    (.Anonymous, supported: noTokenReqd + anonymous, unsupported: authdOnly),
                    (.Authenticated, supported: authdOnly, unsupported: []),
                    (.Initial, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.UserCredsSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.ShouldTryUserCreds, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.RefreshTokenSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.ShouldTryRefreshToken, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.AnonymousCredsSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.ShouldTryAnonymousCreds, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                ]

                for (state, supported, unsupported) in expectations {
                    for supportedEndpoint in supported {
                        it("\(state) should support \(supportedEndpoint)") {
                            expect(state.supports(supportedEndpoint)) == true
                        }
                    }
                    for unsupportedEndpoint in unsupported {
                        it("\(state) should not support \(unsupportedEndpoint)") {
                            expect(state.supports(unsupportedEndpoint)) == false
                        }
                    }
                }
            }
        }
    }
}
