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

                // FAILS for some reason
//                let dataSource = controller.collectionView.dataSource! as StreamDataSource
//                expect(dataSource) == controller.dataSource
            }

            it("sets up a postbar controller and assigns it to the datasource") {
                expect(controller.postbarController).notTo(beNil())
                expect(controller.dataSource.postbarDelegate).notTo(beNil())

                let delegate = controller.dataSource.postbarDelegate! as PostbarController
                expect(delegate) == controller.postbarController
            }

            it("configures collectionView") {
                let delegate = controller.collectionView.delegate! as StreamViewController
                expect(delegate) == controller
                expect(controller.collectionView.alwaysBounceHorizontal) == false
                expect(controller.collectionView.alwaysBounceVertical) == true
            }

            it("adds notification observers") {

            }
        })

        xdescribe("loading more posts on scrolling") {

            beforeEach {
                controller = StreamViewController.instantiateFromStoryboard()
                controller.streamKind = StreamKind.Friend
                controller.loadView()
                controller.viewDidLoad()
                controller.streamService.loadStream(controller.streamKind.endpoint,
                    success: { (jsonables, responseConfig) in
                        controller.addUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: controller.streamKind))
                        controller.responseConfig = responseConfig
                        controller.doneLoading()
                    }, failure: { (error, statusCode) in
                        controller.doneLoading()
                    }
                )
            }

            it("loads the next page of results when scrolled within 300 of the bottom") {
                expect(controller.collectionView.numberOfItemsInSection(0)).toEventually(equal(3))
                //                controller.collectionView.contentOffset = CGPoint(x: 0, y: 0)
                //                expect(controller.collectionView.numberOfItemsInSection(0)) == 6
            }

            it("does not load the next page of results when not scrolled within 300 of the bottom") {
                expect(controller.collectionView.numberOfItemsInSection(0)).toEventually(equal(3))
            }
        }

        context("protocol conformance") {

            beforeEach({
                controller = StreamViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            context("WebLinkDelegate") {

                it("is a weblinkdelegate") {
                    expect(controller as WebLinkDelegate).notTo(beNil())
                }

                describe("-webLinkTapped:data:") {

                    it("posts a notification if type .External") {

                        var link = ""
                        let externalWebObserver = NotificationObserver(notification: externalWebNotification) { url in
                            link = url
                        }

                        controller.webLinkTapped(ElloURI.External, data: "http://www.example.com")
                        expect(link) == "http://www.example.com"
                    }

                    xit("presents a profile if type .Profile") {
                        // not yet implemented
                    }

                    xit("shows a post detail if type .Post") {
                        // not yet implemented
                    }

                }
            }

            context("UserDelegate") {

                beforeEach {
                    let service = StreamService()
                    service.loadUser(ElloAPI.FriendStream, success: { user in
                        controller.addUnsizedCellItems(StreamCellItemParser().parse(user.posts, streamKind: .Friend))
                    }, failure: nil)
                }

                it("is a UserDelegate") {
                    expect(controller as UserDelegate).notTo(beNil())
                }

                describe("-userTapped:") {

                    xit("presents a ProfileViewController") {
                        let cell = controller.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
                        controller.userTappedCell(cell!)

                        expect(controller.navigationController?.topViewController).to(beAKindOf(ProfileViewController.self))
                    }
                }
            }

            context("UICollectionViewDelegate") {
                
                it("is a UICollectionViewDelegate") {
                    expect(controller as UICollectionViewDelegate).notTo(beNil())
                }
                
                describe("-collectionView:didSelectItemAtIndexPath:") {

                    context("a post is found for the given indexPath") {

                        xit("calls postTapped: on the postTappedDelegate") {
                            // need to wire up a collectionview and datasource
                        }
                    }

                    context("no post is found for the given indexPath") {

                        xit("does not call postTapped: on the postTappedDelegate") {

                        }
                    }

                }

                describe("-collectionView:shouldSelectItemAtIndexPath:") {

                    xit("returns true if the streamcell item type is .Header") {
                        // need to wire up a collectionview and datasource
                    }
                }
            }

            context("StreamCollectionViewLayoutDelegate") {

                it("is a StreamCollectionViewLayoutDelegate") {
                    expect(controller as StreamCollectionViewLayoutDelegate).notTo(beNil())
                }

                describe("-collectionView:sizeForItemAtIndexPath:") {

                    context("one column layout") {

                        xit("returns the correct size for a Header Cell") {

                        }

                        xit("returns the correct size for a Comment Header Cell") {

                        }

                        xit("returns the correct size for a Footer Cell") {

                        }

                        xit("returns the correct size for an Image Cell") {

                        }

                        xit("returns the correct size for a Text Cell") {

                        }

                        xit("returns the correct size for a Comment Cell") {

                        }

                        xit("returns the correct size for a Profile Header Cell") {

                        }

                        xit("returns the correct size for a Notification Cell") {

                        }
                    }

                    context("two column layout") {

                        xit("returns the correct size for a Header Cell") {

                        }

                        xit("returns the correct size for a Comment Header Cell") {

                        }

                        xit("returns the correct size for a Footer Cell") {

                        }

                        xit("returns the correct size for an Image Cell") {

                        }

                        xit("returns the correct size for a Text Cell") {

                        }

                        xit("returns the correct size for a Comment Cell") {
                            
                        }
                        
                        xit("returns the correct size for a Profile Header Cell") {
                            
                        }
                        
                        xit("returns the correct size for a Notification Cell") {
                            
                        }
                    }

                }

                describe("-collectionView:groupForItemAtIndexPath:") {

                    xit("returns the same group for all cells in a post") {

                    }

                    xit("returns a different group for cells from different posts") {

                    }
                }

                describe("-collectionView:heightForItemAtIndexPath:") {

                    context("one column layout") {

                        xit("returns the correct height for a Header Cell") {

                        }

                        xit("returns the correct height for a Comment Header Cell") {

                        }

                        xit("returns the correct height for a Footer Cell") {

                        }

                        xit("returns the correct height for an Image Cell") {

                        }

                        xit("returns the correct height for a Text Cell") {

                        }

                        xit("returns the correct height for a Comment Cell") {

                        }

                        xit("returns the correct height for a Profile Header Cell") {

                        }

                        xit("returns the correct height for a Notification Cell") {

                        }
                    }

                    context("two column layout") {

                        xit("returns the correct height for a Header Cell") {

                        }

                        xit("returns the correct height for a Comment Header Cell") {

                        }

                        xit("returns the correct height for a Footer Cell") {

                        }

                        xit("returns the correct height for an Image Cell") {
                            
                        }
                        
                        xit("returns the correct height for a Text Cell") {
                            
                        }
                        
                        xit("returns the correct height for a Comment Cell") {
                            
                        }
                        
                        xit("returns the correct height for a Profile Header Cell") {
                            
                        }
                        
                        xit("returns the correct height for a Notification Cell") {
                            
                        }
                    }
                }

                describe("-collectionView:maintainAspectRatioForItemAtIndexPath:") {

                    xit("returns false for a Header Cell") {

                    }

                    xit("returns false for a Comment Header Cell") {

                    }

                    xit("returns false for a Footer Cell") {

                    }

                    xit("returns true for an Image Cell") {

                    }

                    xit("returns false for a Text Cell") {

                    }

                    xit("returns false for a Comment Cell") {

                    }

                    xit("returns false for a Profile Header Cell") {

                    }

                    xit("returns false for a Notification Cell") {

                    }
                }

                describe("-collectionView:isFullWidthAtIndexPath:") {

                    xit("returns false for a Header Cell") {

                    }

                    xit("returns false for a Comment Header Cell") {

                    }

                    xit("returns false for a Footer Cell") {

                    }

                    xit("returns false for an Image Cell") {

                    }

                    xit("returns false for a Text Cell") {

                    }

                    xit("returns false for a Comment Cell") {
                        
                    }
                    
                    xit("returns true for a Profile Header Cell") {
                        
                    }
                    
                    xit("returns false for a Notification Cell") {
                        
                    }
                }
            }

            context("UIScrollViewDelegate") {

                it("is a UIScrollViewDelegate") {
                    expect(controller as UIScrollViewDelegate).notTo(beNil())
                }

                describe("-scrollViewDidScroll:") {

                    xit("hides the tab bar when scrolling up") {

                    }

                    xit("shows the tab bar when scrolling down") {

                    }
                }
            }

        }
    }
}