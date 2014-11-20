//
//  ElloTests.swift
//  ElloTests
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class ElloSpec: QuickSpec {
    override func spec() {
        describe("get up and running", { () -> () in

            var sound = "blah"

            beforeEach({ () -> () in
                 sound = "Woof"
            })

            it("the sound is woof") {
                expect(sound).to(equal("Woof"))
            }
        })
    }
}
