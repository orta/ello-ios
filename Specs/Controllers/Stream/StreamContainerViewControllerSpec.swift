//
//  StreamContainerViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble
import SwiftyUserDefaults


class StreamContainerViewControllerSpec: QuickSpec {
    override func spec() {
        describe("StreamContainerViewController") {

            var controller: StreamContainerViewController!

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

            describe("recalling previously viewed stream") {
                it("should have a default currentStreamIndex") {
                    Defaults[CurrentStreamKey] = nil
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    expect(controller.currentStreamIndex) == 0
                }

                it("should store the currentStreamIndex") {
                    Defaults[CurrentStreamKey] = 1
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    expect(controller.currentStreamIndex) == 1
                }

                it("should move the scroll view") {
                    Defaults[CurrentStreamKey] = 1
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    self.showController(controller)
                    expect(controller.scrollView.contentOffset) == CGPoint(x: UIScreen.mainScreen().bounds.size.width, y: 0)
                }

                it("should update the currentStreamIndex") {
                    Defaults[CurrentStreamKey] = 0
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    self.showController(controller)
                    controller.streamsSegmentedControl.selectedSegmentIndex = 1
                    controller.streamSegmentTapped(controller.streamsSegmentedControl)
                    expect(controller.currentStreamIndex) == 1
                }
            }

            describe("-viewDidLoad:") {

                beforeEach {
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    controller.loadView()
                    controller.viewDidLoad()
                }

                it("has streams") {
                    expect(controller.streamControllerViews.count) == 2
                }

                it("IBActions are wired up") {
                    let streamsSegmentedControlActions = controller.streamsSegmentedControl.actionsForTarget(controller, forControlEvent: UIControlEvents.ValueChanged)

                    expect(streamsSegmentedControlActions).to(contain("streamSegmentTapped:"))

                    expect(streamsSegmentedControlActions?.count) == 1
                }
            }
        }
    }
}

