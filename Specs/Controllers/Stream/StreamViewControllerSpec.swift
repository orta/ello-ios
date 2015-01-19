//
//  StreamViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class StreamViewControllerSpec: QuickSpec {
    override func spec() {
        
        var controller = StreamViewController.instantiateFromStoryboard()
        describe("initialization", {
            
            beforeEach({
                controller = StreamViewController.instantiateFromStoryboard()
            })
            
            describe("storyboard", {
                
                beforeEach({
                    controller.loadView()
                    controller.viewDidLoad()
                })
                
                it("IBOutlets are  not nil", {
                    expect(controller.scrollView).notTo(beNil())
                })

            })
            
            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }
            
            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })
            
            it("is a StreamViewController", {
                expect(controller).to(beAKindOf(StreamViewController.self))
            })
            
            it("has a tab bar item", {
                expect(controller.tabBarItem).notTo(beNil())
                
                let selectedImage:UIImage = controller.navigationController!.tabBarItem.valueForKey("selectedImage") as UIImage
                
                expect(selectedImage).notTo(beNil())
            })
        })
        
        describe("-viewDidLoad:", {
            
            beforeEach({
                controller = StreamViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })
            
            it("has 2 streams", {
                expect(countElements(controller.streamControllerViews)) == 2
                expect(countElements(controller.streamControllers)) == 2
            })
            
            it("hides the nav bar on swipe") {
                expect(controller.navigationController?.hidesBarsOnSwipe) == true
            }
            
            it("IBActions are wired up", {
                let streamsSegmentedControlActions = controller.streamsSegmentedControl.actionsForTarget(controller, forControlEvent: UIControlEvents.ValueChanged)
                
                expect(streamsSegmentedControlActions).to(contain("streamSegmentTapped:"))
                
                expect(streamsSegmentedControlActions?.count) == 1
            });

        })
    }
}

