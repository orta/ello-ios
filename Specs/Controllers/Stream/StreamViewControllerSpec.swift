//
//  StreamViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class StreamViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = StreamViewController.instantiateFromStoryboard()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

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
                    expect(controller.collectionView).notTo(beNil())
                })
            })

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a StreamViewController", {
                expect(controller).to(beAKindOf(StreamViewController.self))
            })

        })

        describe("-viewDidLoad:", {

            beforeEach({
                controller = StreamViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            it("properly configures dataSource") {
                expect(controller.dataSource).to(beAnInstanceOf(StreamDataSource.self))
            }

            // TODO: fix error about delegate not found
            it("configures collectionView") {
//                expect(controller.collectionView.delegate) == controller
                expect(controller.collectionView.alwaysBounceHorizontal) == false
                expect(controller.collectionView.alwaysBounceVertical) == true
            }

            it("adds notification observers") {

            }
        })
    }
}