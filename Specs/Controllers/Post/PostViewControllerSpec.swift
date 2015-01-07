//
//  PostViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class PostViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        var controller = PostViewController.instantiateFromStoryboard()
        describe("initialization", {

            beforeEach({
                controller = PostViewController.instantiateFromStoryboard()
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

            it("is a PostViewController", {
                expect(controller).to(beAKindOf(PostViewController.self))
            })
        })
    }
}
