//
//  IntroControllerSpec.swift
//  Ello
//
//  Created by Brandon Brisbon on 5/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class IntroControllerSpec: QuickSpec {
    override func spec() {
        
        var controller = IntroController()
        describe("initialization") {
            
            beforeEach {
                controller = IntroController()
            }
            
            it("can be instantiated") {
                expect(controller).notTo(beNil())
            }
            
            it("is a UIViewController") {
                expect(controller).to(beAKindOf(UIViewController.self))
            }
            
            it("is a IntroController") {
                expect(controller).to(beAKindOf(IntroController.self))
            }
        }
    }
}
