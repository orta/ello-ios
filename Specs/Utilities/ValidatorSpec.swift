//
//  ValidatorSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class ValidatorSpec: QuickSpec {
    override func spec() {

        context("email validation", {

            it("returns true for a valid email") {
                var email = "name@test.com"
                expect(email.isValidEmail()) == true

                email = "n@t.co"
                expect(email.isValidEmail()) == true

                email = "n@t.shopping"
                expect(email.isValidEmail()) == true

                email = "some.name@domain.co.uk"
                expect(email.isValidEmail()) == true

                email = "some+name@domain.somethingreallylong"
                expect(email.isValidEmail()) == true
            }

            it("returns false for an invalid email") {
                var email = "test.com"
                expect(email.isValidEmail()) == false

                email = "name@test"
                expect(email.isValidEmail()) == false

                email = "name@.com"
                expect(email.isValidEmail()) == false

                email = "name@name.com."
                expect(email.isValidEmail()) == false

                email = "name@name.t"
                expect(email.isValidEmail()) == false

                email = ""
                expect(email.isValidEmail()) == false
            }

        })

        context("password validation", {

            it("returns true for a valid password") {
                var password = "asdfasdf"
                expect(password.isValidPassword()) == true

                password = "123456789"
                expect(password.isValidPassword()) == true
            }

            it("returns false for an invalid password") {
                var password = ""
                expect(password.isValidPassword()) == false
            }
            
        })

    }
}

