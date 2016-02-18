//
//  ElloManagerSpec.swift
//  Ello
//
//  Created by Sean on 2/12/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Moya
import Nimble
import Alamofire

class ElloManagerSpec: QuickSpec {
    override func spec() {

        describe("ElloManager") {
            afterEach {
                AppSetup.sharedState.isSimulator = nil
            }

            describe("serverTrustPolicies") {

                it("has one when not in the simulator") {
                    AppSetup.sharedState.isSimulator = false
                    // TODO: figure out how to mock UIDevice.currentDevice().model
                    expect(ElloManager.serverTrustPolicies["ello.co"]).notTo(beNil())
                }

                it("has zero when in the simulator") {
                    AppSetup.sharedState.isSimulator = true
                    expect(ElloManager.serverTrustPolicies["ello.co"]).to(beNil())
                }
            }

            describe("SSL Pinning") {

                it("has a custom Alamofire.Manager") {
                    let defaultManager = Alamofire.Manager.sharedInstance
                    let elloManager = ElloManager.manager

                    expect(elloManager).notTo(beIdenticalTo(defaultManager))
                }

                it("includes 2 ssl certificates in the app") {
                    AppSetup.sharedState.isSimulator = false
                    let policy = ElloManager.serverTrustPolicies["ello.co"]!
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
        }
    }
}
