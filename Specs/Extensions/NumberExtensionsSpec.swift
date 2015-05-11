//
//  NumberExtensionSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class NumberExtensionsSpec: QuickSpec {
    override func spec() {

        it("returns 123 with 123") {
            expect(123.numberToHuman()).to(equal("123"))
        }

        it("returns 1.23K with 1234") {
            expect(1234.numberToHuman()).to(equal("1.23K"))
        }

        it("returns 12.35K with 12345") {
            expect(12345.numberToHuman()).to(equal("12.35K"))
        }

        it("returns 1.23M with 1234567") {
            expect(1234567.numberToHuman()).to(equal("1.23M"))
        }

        it("returns 1.23B with 1234567890") {
            expect(1234567890.numberToHuman()).to(equal("1.23B"))
        }
    }
}