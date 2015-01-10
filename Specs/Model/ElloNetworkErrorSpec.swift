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
            let code = "rate_limited"
            let title = "The request could not be handled due to rate limiting."
            let status = "420"
            let detail = "sample test detail"
            let messages = ["message one", "message two", "message three"]
            let nameAttrs = ["can't be blank", "too $hort"]
            let addressAttrs = ["too long"]
            let attrs = ["name" : nameAttrs, "address" : addressAttrs]
            let errors:[String:AnyObject] = ["status" : status, "title" : title, "code" : code, "detail" : detail, "messages" : messages, "attrs" : attrs]
            let data:[String: AnyObject] = ["errors" : errors]

            let elloNetworkError = ElloNetworkError.fromJSON(data, linked: nil) as ElloNetworkError

            expect(elloNetworkError.code) == ElloNetworkError.CodeType.rateLimited
            expect(elloNetworkError.title) == title
            expect(elloNetworkError.status) == status
            expect(elloNetworkError.detail) == detail
            expect(elloNetworkError.messages) == messages
            expect(elloNetworkError.attrs!["name"]!) == nameAttrs
            expect(elloNetworkError.attrs!["address"]!) == addressAttrs
            expect((elloNetworkError.errors["status"] as String)) == status
            expect((elloNetworkError.errors["title"] as String)) == title
            expect((elloNetworkError.errors["code"] as String)) == code
            expect((elloNetworkError.errors["detail"] as String)) == detail
            expect((elloNetworkError.errors["messages"] as [String])) == messages
            
            expect(elloNetworkError.detail) == detail
        }
    }

}
