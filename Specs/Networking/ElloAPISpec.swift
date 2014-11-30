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
                describe("a provider", { () -> () in
                    var provider: MoyaProvider<ElloAPI>!
                    beforeEach {
                        provider = MoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
                    }

                    it("returns stubbed data for posts request") {
                        var message: String?

                        let target: ElloAPI = .Posts
                        provider.request(target, completion: { (data, statusCode, response, error) in
                            if let data = data {
                                message = NSString(data: data, encoding: NSUTF8StringEncoding)
                            }
                        })

                        let sampleData = target.sampleData as NSData
                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                    }

//                    it("returns stubbed data for xauth request") {
//                        var message: String?
//
//                        let target: ElloAPI = .XAuth
//                        provider.request(target, completion: { (data, statusCode, response, error) in
//                            if let data = data {
//                                message = NSString(data: data, encoding: NSUTF8StringEncoding)
//                            }
//                        })
//
//                        let sampleData = target.sampleData as NSData
//                        expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
//                    }
                })
            }

        }
    }
}
