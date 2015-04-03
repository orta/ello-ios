//
//  StreamContainerViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class StreamContainerViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = StreamContainerViewController.instantiateFromStoryboard()
        describe("initialization") {

            beforeEach {
                controller = StreamContainerViewController.instantiateFromStoryboard()
            }

            describe("storyboard") {

                beforeEach {
                    controller.loadView()
                    controller.viewDidLoad()
                }

                it("IBOutlets are  not nil") {
                    expect(controller.scrollView).notTo(beNil())
                    expect(controller.navigationBar).notTo(beNil())
                    expect(controller.navigationBarTopConstraint).notTo(beNil())
                }

            }

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a StreamContainerViewController") {
                expect(controller).to(beAKindOf(StreamContainerViewController.self))
            }

            it("has a tab bar item") {
                expect(controller.tabBarItem).notTo(beNil())

                let selectedImage:UIImage = controller.navigationController!.tabBarItem.valueForKey("selectedImage") as! UIImage

                expect(selectedImage).notTo(beNil())
            }
        }

        describe("-viewDidLoad:") {

            beforeEach {
                controller = StreamContainerViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            }

            it("has streams") {
                expect(count(controller.streamControllerViews)) == 2
            }

            it("IBActions are wired up") {
                let streamsSegmentedControlActions = controller.streamsSegmentedControl.actionsForTarget(controller, forControlEvent: UIControlEvents.ValueChanged)

                expect(streamsSegmentedControlActions).to(contain("streamSegmentTapped:"))

                expect(streamsSegmentedControlActions?.count) == 1
            }
        }
    }
}

