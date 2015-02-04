//
//  SettingsViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class SettingsViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = SettingsViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = SettingsViewController.instantiateFromStoryboard()
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a SettingsViewController", {
                expect(controller).to(beAKindOf(SettingsViewController.self))
            })
            
            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())
                
                let selectedImage:UIImage = controller.tabBarItem.valueForKey("selectedImage") as UIImage
                
                expect(selectedImage).notTo(beNil())
            })
        })
    }
}

