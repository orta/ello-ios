//
//  ElloAPISpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Quick
import Moya
import Nimble

class ElloAPISpec: QuickSpec {
    override func spec() {
        describe("valid enpoints") {
            describe("with stubbed responses") {
                describe("a provider", {
                    var provider: MoyaProvider<ElloAPI>!
                    beforeEach {
                        provider = ElloProvider.StubbingProvider()
                    }

                    it("returns stubbed data for auth request") {
                        var message: String?

                        let target: ElloAPI = .Auth(email:"test@example.com", password: "123456")
                        provider.request(target, completion: { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding)
                            }
                        })

                        let sampleData = target.sampleData as NSData
                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                    }

                    it("returns stubbed data for friends stream request") {
                        var message: String?

                        let target: ElloAPI = .FriendStream
                        provider.request(target, completion: { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding)
                            }
                        })

                        let sampleData = target.sampleData as NSData
                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                    }
                })
            }

        }
    }
}
