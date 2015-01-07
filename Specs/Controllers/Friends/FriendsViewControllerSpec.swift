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

        var controller = FriendsViewController.instantiateFromStoryboard()
        
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
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
        
        describe("-viewDidLoad:", {
            
            beforeEach({
                controller = FriendsViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })
            
            it("properly configures dataSource") {
                expect(controller.dataSource).to(beAnInstanceOf(FriendsDataSource.self))
            }
            
            it("hides the nav bar on swipe") {
                expect(controller.navigationController?.hidesBarsOnSwipe) == true
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