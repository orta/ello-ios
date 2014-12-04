//
//  FriendsViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class FriendsViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        var controller = FriendsViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = FriendsViewController.instantiateFromStoryboard()
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

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a FriendsViewController", {
                expect(controller).to(beAKindOf(FriendsViewController.self))
            })
        })
    }
}