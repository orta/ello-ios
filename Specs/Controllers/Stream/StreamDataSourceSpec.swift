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
        let indexPath0 = NSIndexPath(forItem: 0, inSection: 0)
        let indexPathOutOfBounds = NSIndexPath(forItem: 1000, inSection: 0)
        let indexPathInvalidSection = NSIndexPath(forItem: 0, inSection: 10)

        var vc:StreamViewController!
        var subject: StreamDataSource!
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))

        beforeEach {
            ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)

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
        }


        context("initialization") {

            it("has streamKind") {
                expect(subject.streamKind).toNot(beNil())
            }

            it("has textSizeCalculator") {
                expect(subject.textSizeCalculator).toNot(beNil())
            }

            it("has notificationSizeCalculator") {
                expect(subject.notificationSizeCalculator).toNot(beNil())
            }

        }

        describe("-collectionView:numberOfItemsInSection:") {

            it("returns the correct number of rows") {
                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 11
            }

        }

        describe("-postForIndexPath:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            it("returns a post") {
                expect(subject.postForIndexPath(indexPath0)).to(beAKindOf(Post.self))
            }

            it("returns nil when out of bounds") {
                expect(subject.postForIndexPath(indexPathOutOfBounds)).to(beNil())
            }

            it("returns nil when invalid section") {
                expect(subject.postForIndexPath(indexPathInvalidSection)).to(beNil())
            }

            it("returns nil when the subject is not a post") {
                // the loaded stream is all posts, need to tweak the data
                expect(subject.postForIndexPath(NSIndexPath(forItem: 8, inSection: 0))).to(beNil())
            }

        }

        describe("-cellItemsForPost:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            it("returns an array of StreamCellItems") {
                var post = subject.postForIndexPath(indexPath0)
                let items = subject.cellItemsForPost(post!)

                expect(countElements(items)) == 7
            }

            it("returns empty array if post not found") {
                let randomPost = Post(assets: nil, author: nil, collapsed: false, commentsCount: nil, content: nil, createdAt: NSDate(), href: "blah", postId: "notfound", repostsCount: nil, summary: nil, token: "noToken", viewsCount: nil)
                let items = subject.cellItemsForPost(randomPost)

                expect(countElements(items)) == 0
            }

            it("does not return cell items for other posts") {

                var post = subject.postForIndexPath(NSIndexPath(forItem:11, inSection: 0))
                let items = subject.cellItemsForPost(post!)

                expect(countElements(items)) == 7
            }
            
        }

        describe("-userForIndexPath:") {

            it("returns a User") {
                expect(subject.userForIndexPath(indexPath0)).to(beAKindOf(User.self))
            }

            it("returns nil when out of bounds") {
                expect(subject.userForIndexPath(indexPathOutOfBounds)).to(beNil())
            }

            it("returns nil when invalid section") {
                expect(subject.userForIndexPath(indexPathInvalidSection)).to(beNil())
            }

            xit("returns nil when the indexPath does not have an author") {
                // the loaded stream does not have any non-author content yet
            }
            
        }

        describe("-commentIndexPathsForPost:") {

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

            it("returns an array of comment index paths") {
                var post = subject.postForIndexPath(indexPath0)
                let indexPaths = subject.commentIndexPathsForPost(post!)

                expect(countElements(indexPaths)) == 4
                expect(indexPaths[0].item) == 7
                expect(indexPaths[1].item) == 8
                expect(indexPaths[2].item) == 9
                expect(indexPaths[3].item) == 10
            }

            it("does not return index paths for comments from another post") {

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
            }
        }

        describe("-updateHeightForIndexPath:") {

            it("updates the height of an existing StreamCellItem") {
                subject.updateHeightForIndexPath(indexPath0, height: 256)

                expect(subject.streamCellItems[0].oneColumnCellHeight) == 266
                expect(subject.streamCellItems[0].multiColumnCellHeight) == 266
            }

            it("handles non-existent index paths") {
                expect(subject.updateHeightForIndexPath(indexPathOutOfBounds, height: 256))
                    .notTo(raiseException())
            }

            it("handles invalid section") {
                expect(subject.updateHeightForIndexPath(indexPathInvalidSection, height: 256))
                    .notTo(raiseException())
            }
        }

        describe("-heightForIndexPath:numberOfColumns") {
            // Need to test this but the sell sizers are not synchronous and are a pain in the ass
            xit("returns the correct height") {}

            it("returns 0 when out of bounds") {
                expect(subject.heightForIndexPath(indexPathOutOfBounds, numberOfColumns: 0)) == 0
            }

            it("returns 0 when invalid section") {
                expect(subject.heightForIndexPath(indexPathInvalidSection, numberOfColumns: 0)) == 0
            }
        }

        describe("-isFullWidthAtIndexPath:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            xit("returns true for ProfileHeaderCells") {
            }

            xit("returns false for all other cells") {
            }

            it("returns true when out of bounds") {                
                expect(subject.isFullWidthAtIndexPath(indexPathOutOfBounds)) == true
            }

            it("returns true when invalid section") {
                expect(subject.isFullWidthAtIndexPath(indexPathInvalidSection)) == true
            }
            
        }

        describe("-maintainAspectRatioForItemAtIndexPath:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            it("returns false") {
                let cellCount = subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)

                for index in 0..<cellCount {
                    expect(subject.maintainAspectRatioForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))) == false
                }
            }
        }

        describe("-groupForIndexPath:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                subject.addUnsizedCellItems(cellItems, startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            it("returns the same value for a post and it's comments") {
                var groupIndexPaths = [NSIndexPath]()
                for index in 0...10 {
                    groupIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }

                for indexPath in groupIndexPaths {
                    expect(subject.groupForIndexPath(indexPath)) == "555"
                }
            }

            it("does not return the same value for two different posts") {
                let firstPostIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                let secondPostIndexPath = NSIndexPath(forItem: 11, inSection: 0)

                let firstGroupId = subject.groupForIndexPath(firstPostIndexPath)
                let secondGroupId = subject.groupForIndexPath(secondPostIndexPath)

                expect(firstGroupId) != secondGroupId
            }

            it("returns '0' if indexPath out of bounds") {
                expect(subject.groupForIndexPath(indexPathOutOfBounds)) == "0"
            }

            it("returns '0' if invalid section") {
                expect(subject.groupForIndexPath(indexPathInvalidSection)) == "0"
            }

            it("returns '0' if StreamCellItem's jsonable is not Authorable") {

                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                let nonAuthorable = Asset(assetId: "123", hdpi: nil, xxhdpi: nil)
                let cellItem = StreamCellItem(jsonable: nonAuthorable, type: .Image, data: nil, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                subject.addUnsizedCellItems([cellItem], startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }

                expect(subject.groupForIndexPath(indexPath0)) == "0"
            }
        }

        describe("-collectionView:cellForItemAtIndexPath:") {

            beforeEach {
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator)

                subject.addUnsizedCellItems(ModelHelper.allCellTypes(), startingIndexPath:nil) { cellCount in
                    vc.collectionView.dataSource = subject
                    vc.collectionView.reloadData()
                }
            }

            describe("with posts") {
                it("returns a StreamHeaderCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
                }

                it("returns a StreamTextCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamTextCell.self))
                }

                it("returns a StreamFooterCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 2, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamFooterCell.self))
                }
            }

            describe("with comments") {
                it("returns a StreamHeaderCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
                }

                it("returns a StreamTextCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 4, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamTextCell.self))
                }
            }

            describe("with users") {
                it("returns a ProfileHeaderCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 5, inSection: 0))
                    expect(cell).to(beAnInstanceOf(ProfileHeaderCell.self))
                }

                it("returns a UserListItemCell") {
                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 6, inSection: 0))
                    expect(cell).to(beAnInstanceOf(UserListItemCell.self))
                }
            }

            xit("returns a NotificationCell") {}

            xit("returns a StreamImageCell") {}

            xit("returns a StreamUnknownCell") {}

            xit("returns a StreamCommentCell") {}
        }
    }
}
