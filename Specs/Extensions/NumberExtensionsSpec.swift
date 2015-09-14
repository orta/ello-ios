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

        let expectations: [Int: String] = [
            123 : "123",
            1234 : "1.23K",
            12345 : "12.35K",
            1234567 : "1.23M",
            1234567890 : "1.23B",
        ]

        for (number, expected) in expectations {
            it("returns \(expected) with \(number)") {
                expect(number.numberToHuman()) == expected
            }
        }

        context("when told to show zero") {
            it("returns 0 for 0") {
                let number = 0
                expect(number.numberToHuman(showZero: true)) == "0"
            }
        }

        context("when not told to show zero") {
            it("returns an empty string for 0") {
                let number = 0
                expect(number.numberToHuman(showZero: false)) == ""
            }
        }
    }
}
