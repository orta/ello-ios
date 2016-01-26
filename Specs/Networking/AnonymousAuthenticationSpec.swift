//
//  AnonymousAuthenticationSpec.swift
//  Ello
//
//  Created by Colin Gray on 1/26/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class AnonymousAuthenticationSpec: QuickSpec {
    override func spec() {
        fdescribe("AnonymousAuthentication") {
            beforeEach {
                AuthToken.reset()
            }

            it("should request anonymous credentials when no credentials are available") {
                ElloProvider.shared.authState = .NoToken

                var succeeded = false
                var failed = false
                ElloProvider.shared.elloRequest(.Availability(content: [:]), success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                })
                expect(AuthToken().token) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(AuthToken().isPasswordBased) == false
                expect(succeeded) == true
                expect(failed) == false
            }

            it("should request anonymous credentials initially when no credentials are available") {
                ElloProvider.shared.authState = .Initial

                var succeeded = false
                var failed = false
                ElloProvider.shared.elloRequest(.Availability(content: [:]), success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                })
                expect(AuthToken().token) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(AuthToken().isPasswordBased) == false
                expect(succeeded) == true
                expect(failed) == false
            }

            it("should fail requests that need authentication when anonymous credentials are available") {
                ElloProvider.shared.authState = .Anonymous

                var succeeded = false
                var failed = false
                ElloProvider.shared.elloRequest(.FriendStream, success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                })
                expect(succeeded) == false
                expect(failed) == true
            }

            it("should fail anonymous requests when anonymous credentials are invalid") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .Availability(content: [:]), response: .NetworkResponse(401, NSData())),
                ])
                ElloProvider.shared.authState = .Anonymous

                var succeeded = false
                var failed = false
                ElloProvider.shared.elloRequest(.Availability(content: [:]), success: { _ in
                    succeeded = true
                }, failure: { _ in
                    failed = true
                })
                expect(succeeded) == false
                expect(failed) == true
            }
        }
    }
}
