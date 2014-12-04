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
            let error = "rate_limited"
            let errorDescription = "The request could not be handled due to rate limiting."
            let messages = ["Name can't be blank"]
            let errors = ["name" : ["can't be blank", "another one"], "email" : ["is too short"]]
            let data:[String: AnyObject] = ["error" : error, "error_description" : errorDescription, "messages" : messages, "errors" : errors]

            let elloNetworkError = ElloNetworkError.fromJSON(data) as ElloNetworkError

            expect(elloNetworkError.error) == error
            expect(elloNetworkError.errorDescription) == errorDescription
            expect(elloNetworkError.messages!) == messages
            expect(elloNetworkError.messages![0]) == "Name can't be blank"
            expect(elloNetworkError.errors!["name"]![0]) == "can't be blank"
            expect(elloNetworkError.errors!["name"]![1]) == "another one"
            expect(elloNetworkError.errors!["email"]![0]) == "is too short"
        }
    }

}
