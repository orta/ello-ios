//
//  StreamDataSourceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
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
        let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame))

        describe("StreamDataSourceSpec") {
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
                    notificationSizeCalculator: notificationSizeCalculator,
                    profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                subject.streamCollapsedFilter = { item in
                    if !item.type.collapsable {
                        return true
                    }
                    if let post = item.jsonable as? Post {
                        return !post.collapsed
                    }
                    return true
                }

                vc.dataSource = subject

                var cellItems = [JSONAble]()
                StreamService().loadStream(ElloAPI.FriendStream,
                    success: { (jsonables, responseConfig) in
                        cellItems = jsonables
                    },
                    failure: nil
                )

                subject.appendUnsizedCellItems(StreamCellItemParser().parse(cellItems, streamKind: .Friend), withWidth: webView.frame.width) { cellCount in
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
                    expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 6
                }

            }

            describe("-postForIndexPath:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
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

            xdescribe("-createCommentIndexPathForPost:") {
                var post: Post? = nil

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    for item in cellItems {
                        if let foundPost = item.jsonable as? Post {
                            post = foundPost
                            break
                        }
                    }

                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an index path for the post") {
                    expect(subject.createCommentIndexPathForPost(post!)).to(beAKindOf(NSIndexPath))
                }

                it("points to a create-comment-item") {
                    if let path = subject.createCommentIndexPathForPost(post!) {
                        if let item = subject.visibleStreamCellItem(at: path) {
                            expect(item.type).to(equal(StreamCellType.CreateComment))
                        }
                        else {
                            fail("no streamCellItem found")
                        }
                    }
                    else {
                        fail("no createCommentIndexPath found")
                    }
                }

            }

            describe("-commentForIndexPath:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns a comment") {
                    let commentIndexPath = NSIndexPath(forItem: 8, inSection: 0)
                    expect(subject.commentForIndexPath(commentIndexPath)).to(beAKindOf(Comment.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.commentForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.commentForIndexPath(indexPathInvalidSection)).to(beNil())
                }

                it("returns nil when the subject is not a comment") {
                    // the loaded stream is all posts, need to tweak the data
                    expect(subject.commentForIndexPath(NSIndexPath(forItem: 0, inSection: 0))).to(beNil())
                }

            }

            describe("-cellItemsForPost:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of StreamCellItems") {
                    var post = subject.postForIndexPath(indexPath0)
                    let items = subject.cellItemsForPost(post!)

                    expect(count(items)) == 8
                }

                it("returns empty array if post not found") {
                    let randomPost: Post = stub(["id": "notfound"])
                    let items = subject.cellItemsForPost(randomPost)

                    expect(count(items)) == 0
                }

                xit("does not return cell items for other posts") {

                    var post = subject.postForIndexPath(NSIndexPath(forItem: 12, inSection: 0))
                    let items = subject.cellItemsForPost(post!)

                    expect(count(items)) == 8
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

            xdescribe("-commentIndexPathsForPost:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForPostWithComments("123")
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of comment index paths") {
                    var post = subject.postForIndexPath(indexPath0)
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(count(indexPaths)) == 5
                    expect(indexPaths[0].item) == 8
                    expect(indexPaths[1].item) == 9
                    expect(indexPaths[2].item) == 10
                    expect(indexPaths[3].item) == 11
                    expect(indexPaths[4].item) == 12
                }

                it("does not return index paths for comments from another post") {

                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }

                    var post = subject.postForIndexPath(NSIndexPath(forItem: 12, inSection: 0))
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(count(indexPaths)) == 5
                    expect(indexPaths[0].item) == 19
                    expect(indexPaths[1].item) == 20
                    expect(indexPaths[2].item) == 21
                    expect(indexPaths[3].item) == 22
                    expect(indexPaths[4].item) == 23
                }
            }

            xdescribe("-removeCommentsForPost:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForPostWithComments("123")
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                    }
                }

                it("removes comment index paths") {
                    var post = subject.postForIndexPath(indexPath0)
                    let indexPaths = subject.removeCommentsForPost(post!)

                    expect(count(indexPaths)) == 5
                    expect(indexPaths[0].item) == 8
                    expect(indexPaths[1].item) == 9
                    expect(indexPaths[2].item) == 10
                    expect(indexPaths[3].item) == 11
                    expect(indexPaths[4].item) == 12
                }

            }

            describe("-updateHeightForIndexPath:") {

                it("updates the height of an existing StreamCellItem") {
                    subject.updateHeightForIndexPath(indexPath0, height: 256)

                    let cellItem = subject.visibleStreamCellItem(at: NSIndexPath(forRow: 0, inSection: 0))
                    expect(cellItem!.oneColumnCellHeight) == 266
                    expect(cellItem!.multiColumnCellHeight) == 266
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

            describe("-removeAllCellItems") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("sets the number of visible cell items to 0") {
                    expect(count(subject.visibleCellItems)) > 0
                    subject.removeAllCellItems()
                    expect(count(subject.visibleCellItems)) == 0
                }

                it("sets the number of cell items to 0") {
                    expect(count(subject.streamCellItems)) > 0
                    subject.removeAllCellItems()
                    expect(count(subject.streamCellItems)) == 0
                }
            }

            describe("-removeCellItemsBelow:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("removes items below the supplied index") {
                    expect(count(subject.visibleCellItems)) == 9
                    subject.removeCellItemsBelow(5)

                    expect(count(subject.visibleCellItems)) == 5
                }
            }

            describe("-visibleStreamCellItem:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns the correct stream cell item") {
                    let item = subject.visibleStreamCellItem(at: NSIndexPath(forItem: 4, inSection:0))

                    expect(item?.type.name) == "StreamHeaderCell"
                }

                it("returns nil if indexpath does not exist") {
                    let item = subject.visibleStreamCellItem(at: NSIndexPath(forItem: 50, inSection:0))

                    expect(item).to(beNil())
                }

            }

            describe("-toggleCollapsedForIndexPath:") {

                beforeEach {
                    subject.removeAllCellItems()
                    let post: Post = stub(["collapsed" : true])
                    subject.removeAllCellItems()
                    let toggleCellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
                    let imageRegion: ImageRegion = stub([:])
                    let imageCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)

                    let anotherPost: Post = stub(["collapsed" : true])
                    let anotherToggleCellItem = StreamCellItem(jsonable: anotherPost, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
                    let anotherImageRegion: ImageRegion = stub([:])
                    let anotherImageCellItem = StreamCellItem(jsonable: anotherPost, type: .Image, data: anotherImageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)

                    subject.appendUnsizedCellItems([toggleCellItem, imageCellItem, anotherToggleCellItem, anotherImageCellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("toggles collapsed on the post at an indexPath") {
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    var post = subject.postForIndexPath(indexPath)!

                    expect(post.collapsed).to(beTrue())

                    subject.toggleCollapsedForIndexPath(indexPath)

                    expect(post.collapsed).to(beFalse())
                }

                it("does not toggle collapsed on other posts") {
                    let indexPathToToggle = NSIndexPath(forItem: 1, inSection: 0)
                    var postToToggle = subject.postForIndexPath(indexPathToToggle)!

                    let indexPathNotToToggle = NSIndexPath(forItem: 0, inSection: 0)
                    var postNotToToggle = subject.postForIndexPath(indexPathNotToToggle)!

                    expect(postToToggle.collapsed).to(beTrue())
                    expect(postNotToToggle.collapsed).to(beTrue())

                    subject.toggleCollapsedForIndexPath(indexPathToToggle)

                    expect(postToToggle.collapsed).to(beFalse())
                    expect(postNotToToggle.collapsed).to(beTrue())
                }
            }

            describe("-isFullWidthAtIndexPath:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
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
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
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
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                xit("returns the same value for a post and it's comments") {
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
                    let secondPostIndexPath = NSIndexPath(forItem: 12, inSection: 0)

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
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    let nonAuthorable: Asset = stub(["id": "123"])

                    let cellItem = StreamCellItem(jsonable: nonAuthorable, type: .Image, data: nil, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)

                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }

                    expect(subject.groupForIndexPath(indexPath0)) == "0"
                }
            }

            describe("-insertUnsizedCellItems:withWidth:startingIndexPath:completion:") {

                beforeEach {
                    subject.removeAllCellItems()
                    let post: Post = stub(["collapsed" : true])
                    subject.removeAllCellItems()
                    let toggleCellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
                    let imageRegion: ImageRegion = stub([:])
                    let imageCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)

                    let anotherPost: Post = stub(["collapsed" : false])
                    let anotherImageRegion: ImageRegion = stub([:])
                    let anotherImageCellItem = StreamCellItem(jsonable: anotherPost, type: .Image, data: anotherImageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)

                    subject.appendUnsizedCellItems([toggleCellItem, imageCellItem, anotherImageCellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("inserts the new cellitems in the correct position") {
                    let comment = ModelHelper.stubComment("456", contentCount: 1, parentPost: Post.stub([:]))
                    let createCommentCellItem = StreamCellItem(jsonable: comment, type: .CreateComment, data: nil, oneColumnCellHeight: StreamCreateCommentCell.Size.Height, multiColumnCellHeight: StreamCreateCommentCell.Size.Height, isFullWidth: true)

                    expect(count(subject.visibleCellItems)) == 1

                    let startingIndexPath = NSIndexPath(forItem: 1, inSection: 0)

                    var expectedIndexPaths = [NSIndexPath]()
                    subject.insertUnsizedCellItems([createCommentCellItem], withWidth: 10.0, startingIndexPath: startingIndexPath ){ (indexPaths) in
                        expectedIndexPaths = indexPaths
                    }

                    let insertedCellItem = subject.visibleCellItems[1]

                    expect(count(subject.visibleCellItems)) == 2

                    expect(insertedCellItem.type.name) == "StreamCreateCommentCell"
                }
            }

            describe("-collectionView:cellForItemAtIndexPath:") {

                beforeEach {
                    subject = StreamDataSource(streamKind: .Friend,
                        textSizeCalculator: textSizeCalculator,
                        notificationSizeCalculator: notificationSizeCalculator,
                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)

                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
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
                        expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
                    }

                    it("returns a StreamFooterCell") {
                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 2, inSection: 0))
                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
                    }
                }

                describe("with comments") {
                    it("returns a StreamHeaderCell") {
                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
                        expect(cell).to(beAnInstanceOf(StreamFooterCell.self))
                    }

                    it("returns a StreamTextCell") {
                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 4, inSection: 0))
                        expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
                    }
                }

                describe("with users") {
                    it("returns a ProfileHeaderCell") {
                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 5, inSection: 0))
                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
                    }

                    it("returns a UserListItemCell") {
                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 6, inSection: 0))
                        expect(cell).to(beAnInstanceOf(ProfileHeaderCell.self))
                    }
                }

                it("returns a NotificationCell") {
                    let notification: Notification = stub([:])
                    subject.removeAllCellItems()
                    let cellItem = StreamCellItem(jsonable: notification, type: .Notification, data: nil, oneColumnCellHeight: 60.0, multiColumnCellHeight: StreamCreateCommentCell.Size.Height, isFullWidth: true)
                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }

                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(cell).to(beAnInstanceOf(NotificationCell.self))
                }

                it("returns a StreamImageCell") {
                    let post: Post = stub([:])
                    let imageRegion: ImageRegion = stub([:])
                    subject.removeAllCellItems()
                    let cellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }

                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamImageCell.self))
                }

                xit("returns a StreamCommentCell") {}

                it("returns a StreamToggleCell") {
                    // Xcode is unable to compile the specs with all the cell types that are generated by the "allCellTypes()" helper in Model Helper
                    let post: Post = stub([:])
                    subject.removeAllCellItems()
                    let cellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }

                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
                    expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
                }
            }
        }
    }
}
