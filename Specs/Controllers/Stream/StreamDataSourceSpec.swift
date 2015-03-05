//
//  StreamDataSourceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class StreamDataSourceSpec: QuickSpec {
    override func spec() {

        var vc = StreamViewController.instantiateFromStoryboard()
        var subject: StreamDataSource!
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
        var loadedPosts:[Post]?

        beforeEach({
            vc = StreamViewController.instantiateFromStoryboard()
            vc.streamKind = StreamKind.Friend
            let keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            keyWindow.makeKeyAndVisible()
            keyWindow.rootViewController = vc
            vc.loadView()
            vc.viewDidLoad()

            subject = StreamDataSource(streamKind: .Friend,
                textSizeCalculator: textSizeCalculator,
                notificationSizeCalculator: notificationSizeCalculator)

            vc.dataSource = subject
            var cellItems = [JSONAble]()
            StreamService().loadStream(ElloAPI.FriendStream,
                success: { (jsonables, responseConfig) in
                    cellItems = jsonables
                },
                failure: nil
            )

            subject.addUnsizedCellItems(StreamCellItemParser().parse(cellItems, streamKind: .Friend), startingIndexPath:nil) { cellCount in
                vc.collectionView.dataSource = subject
                vc.collectionView.reloadData()
            }
        })


        context("initialization", {

            it("has streamKind") {
                expect(subject.streamKind).toNot(beNil())
            }

            it("has textSizeCalculator") {
                expect(subject.textSizeCalculator).toNot(beNil())
            }

            it("has notificationSizeCalculator") {
                expect(subject.notificationSizeCalculator).toNot(beNil())
            }

        })

        describe("-collectionView:numberOfItemsInSection:", {

            it("returns the correct number of rows", {
                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 11
            })

        })

        describe("-postForIndexPath:", {

            it("returns a post", {
                expect(subject.postForIndexPath(NSIndexPath(forItem: 0, inSection: 0))).to(beAKindOf(Post.self))
            })

            it("returns nil when out of bounds", {
                expect(subject.postForIndexPath(NSIndexPath(forItem: 100, inSection: 0))).to(beNil())
            })

            xit("returns nil when the subject is not a post", {
                // the loaded stream is all posts, need to tweak the data
                expect(subject.postForIndexPath(NSIndexPath(forItem: 12, inSection: 0))).to(beNil())
            })

        })

        describe("-cellItemsForPost:", {

            it("returns an array of StreamCellItems", {
                var post = subject.postForIndexPath(NSIndexPath(forItem: 0, inSection: 0))
                let items = subject.cellItemsForPost(post!)

                expect(countElements(items)) == 4
            })

            it("returns empty array if post not found", {
                let randomPost = Post(assets: nil, author: nil, collapsed: false, commentsCount: nil, content: nil, createdAt: NSDate(), href: "blah", postId: "notfound", repostsCount: nil, summary: nil, token: "noToken", viewsCount: nil)
                let items = subject.cellItemsForPost(randomPost)

                expect(countElements(items)) == 0
            })

            it("does not return cell items for other posts") {

                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }

                var post = subject.postForIndexPath(NSIndexPath(forItem:11, inSection: 0))
                let items = subject.cellItemsForPost(post!)

                expect(countElements(items)) == 7
            }
            
        })

        describe("-authorForIndexPath:", {

            it("returns a User", {
                expect(subject.authorForIndexPath(NSIndexPath(forItem: 0, inSection: 0))).to(beAKindOf(User.self))
            })

            it("returns nil when out of bounds", {
                expect(subject.authorForIndexPath(NSIndexPath(forItem: 1000, inSection: 0))).to(beNil())
            })

            xit("returns nil when the indexPath does not have an author", {
                // the loaded stream does not have any non-author content yet
            })
            
        })

        describe("-commentIndexPathsForPost:", {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForPostWithComments("123")
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            it("returns an array of comment index paths", {
                var post = subject.postForIndexPath(NSIndexPath(forItem: 0, inSection: 0))
                let indexPaths = subject.commentIndexPathsForPost(post!)

                expect(countElements(indexPaths)) == 4
                expect(indexPaths[0].item) == 7
                expect(indexPaths[1].item) == 8
                expect(indexPaths[2].item) == 9
                expect(indexPaths[3].item) == 10
            })

            it("does not return index paths for comments from another post", {

                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }

                var post = subject.postForIndexPath(NSIndexPath(forItem:11, inSection: 0))
                let indexPaths = subject.commentIndexPathsForPost(post!)

                expect(countElements(indexPaths)) == 4
                expect(indexPaths[0].item) == 18
                expect(indexPaths[1].item) == 19
                expect(indexPaths[2].item) == 20
                expect(indexPaths[3].item) == 21
            })


        })

        describe("-updateHeightForIndexPath:", {

            it("updates the height of an existing StreamCellItem", {
                subject.updateHeightForIndexPath(NSIndexPath(forItem: 0, inSection: 0), height: 256)

                expect(subject.streamCellItems[0].oneColumnCellHeight) == 266
                expect(subject.streamCellItems[0].multiColumnCellHeight) == 266
            })

            it("handles non-existent index paths", {
                expect(subject.updateHeightForIndexPath(NSIndexPath(forItem: 1000, inSection: 0), height: 256))
                    .notTo(raiseException())
            })
            
        })

        xdescribe("-heightForIndexPath:numberOfColumns", {
            // Need to test this but the sell sizers are not synchronous and are a pain in the ass
        })

        xdescribe("-collectionView:cellForItemAtIndexPath:", {

            it("returns a StreamHeaderCell", {
                let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                expect{cell}.toEventually(beAnInstanceOf(StreamHeaderCell.self))

            })
        })
    }
}
