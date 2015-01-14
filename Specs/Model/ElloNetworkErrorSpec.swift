//
//  elloNetworkError.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class ElloNetworkErrorSpec: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let errors = stubbedJSONData("422", "errors")

            let elloNetworkError = ElloNetworkError.fromJSON(errors, linked: nil) as ElloNetworkError

            expect(elloNetworkError.code) == ElloNetworkError.CodeType.invalidResource
            expect(elloNetworkError.title) == "The current resource was invalid."
            expect(elloNetworkError.status) == "422"
            expect(elloNetworkError.detail).to(beNil())
            expect(elloNetworkError.messages) == ["Name can't be blank"]
            expect(elloNetworkError.attrs!["name"]!) == ["can't be blank"]
        }
    }
}
