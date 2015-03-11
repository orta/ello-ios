//
//  ElloAttributedStringSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/7/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class ElloAttributedStringSpec: QuickSpec {
    override func spec() {
        describe("styling a string") {
            it("returns an attributed string") {
                let text = "text"
                let attrd = ElloAttributedString.style(text)
                expect(attrd).to(beAKindOf(NSAttributedString))
            }
        }
    }
}