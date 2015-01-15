//
//  OmnibarViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {
        
        var controller = OmnibarViewController.instantiateFromStoryboard()
        
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }
        
        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        describe("initialization", {
            
            beforeEach({
                controller = OmnibarViewController.instantiateFromStoryboard()
            })
            
            describe("storyboard", {
                
                beforeEach({
                    controller.loadView()
                    controller.viewDidLoad()
                })
                
                it("IBOutlets are  not nil", {
                })
            })
            
            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a OmnibarViewController", {
                expect(controller).to(beAKindOf(OmnibarViewController.self))
            })
            
            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())
                
                let selectedImage:UIImage = controller.tabBarItem.valueForKey("selectedImage") as UIImage
                
                expect(selectedImage).notTo(beNil())
            })
        })
        
        describe("-viewDidLoad:", {
            
            beforeEach({
                controller = OmnibarViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })
            
            it("configures tableView") {

            }
            
            it("adds notification observers") {
                
            }
        })
    }
}