//
//  AmazonCredentialsSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class AmazonCredentialsSpec: QuickSpec {
    var credentials : AmazonCredentials?

    override func spec() {
        describe("requesting credentials") {
            describe("requesting an AmazonCredentials object") {
                beforeEach() {
                    let endpoint = ElloAPI.AmazonCredentials
                    self.credentials = nil
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                    ElloProvider.shared.elloRequest(endpoint,
                                    success: { credentialsData, responseConfig in
                            if let credentials = credentialsData as? AmazonCredentials {
                                self.credentials = credentials
                            }
                        },
                        failure: nil)
                }
                it("should not be nil") {
                    expect(self.credentials).toNot(beNil())
                }
                it("should set the prefix") {
                    expect(self.credentials!.prefix).to(equal("uploads/prefix"))
                }
                it("should set the policy") {
                    expect(self.credentials!.policy).to(equal("prolicy-hash"))
                }
                it("should set the signature") {
                    expect(self.credentials!.signature).to(equal("signature-hash"))
                }
                it("should set the endpoint") {
                    expect(self.credentials!.endpoint).to(equal("https://endpoint.amazonaws.com"))
                }
                it("should set the access_key") {
                    expect(self.credentials!.accessKey).to(equal("access-key"))
                }
            }
        }
    }
}
