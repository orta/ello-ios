//
//  ColorsSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ColorsSpec: QuickSpec {
    override func spec() {

        describe("color methods") {
            it("+grey231F20") {
                expect(UIColor.grey231F20()).to(beAKindOf(UIColor))
            }
            it("+grey3") {
                expect(UIColor.grey3()).to(beAKindOf(UIColor))
            }
            it("+grey4D") {
                expect(UIColor.grey4D()).to(beAKindOf(UIColor))
            }
            it("+grey6") {
                expect(UIColor.grey6()).to(beAKindOf(UIColor))
            }
            it("+greyA") {
                expect(UIColor.greyA()).to(beAKindOf(UIColor))
            }
            it("+greyE5") {
                expect(UIColor.greyE5()).to(beAKindOf(UIColor))
            }
            it("+greyF1") {
                expect(UIColor.greyF1()).to(beAKindOf(UIColor))
            }
            it("+yellowFFFFCC") {
                expect(UIColor.yellowFFFFCC()).to(beAKindOf(UIColor))
            }
            it("+redFFCCCC") {
                expect(UIColor.redFFCCCC()).to(beAKindOf(UIColor))
            }
        }
    }
}
