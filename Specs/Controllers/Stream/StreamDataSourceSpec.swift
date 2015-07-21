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

public class FakeCollectionView: UICollectionView {

    public override func insertItemsAtIndexPaths(indexPaths: [AnyObject]) {
        // noop
    }

    public override func deleteItemsAtIndexPaths(indexPaths: [AnyObject]) {
        // noop
    }

    public override func reloadItemsAtIndexPaths(indexPaths: [AnyObject]) {
        // noop
    }
}

class StreamDataSourceSpec: QuickSpec {

    override func spec() {
        let indexPath0 = NSIndexPath(forItem: 0, inSection: 0)
        let indexPathOutOfBounds = NSIndexPath(forItem: 1000, inSection: 0)
        let indexPathInvalidSection = NSIndexPath(forItem: 0, inSection: 10)

        var vc: StreamViewController!
        var subject: StreamDataSource!
        var fakeCollectionView: FakeCollectionView!

        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let imageSizeCalculator = StreamImageCellSizeCalculator()

        describe("StreamDataSourceSpec") {
            beforeEach {
                ElloProvider.sharedProvider = MoyaProvider(endpointClosure: ElloProvider.endpointClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour)
                vc = StreamViewController.instantiateFromStoryboard()
                vc.streamKind = StreamKind.Friend
                subject = StreamDataSource(streamKind: .Friend,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator,
                    profileHeaderSizeCalculator: profileHeaderSizeCalculator,
                    imageSizeCalculator: imageSizeCalculator)

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
                self.showController(vc)
                fakeCollectionView = FakeCollectionView(frame: vc.collectionView.frame, collectionViewLayout: vc.collectionView.collectionViewLayout)

            }

            afterEach {
                subject.removeAllCellItems()
            }

            describe("init(streamKind:textSizeCalculator:notificationSizeCalculator:profileHeaderSizeCalculator:)") {

                it("has streamKind") {
                    expect(subject.streamKind).toNot(beNil())
                }

                it("has textSizeCalculator") {
                    expect(subject.textSizeCalculator).toNot(beNil())
                }

                it("has notificationSizeCalculator") {
                    expect(subject.notificationSizeCalculator).toNot(beNil())
                }

                it("has profileHeaderSizeCalculator") {
                    expect(subject.profileHeaderSizeCalculator).toNot(beNil())
                }
            }

            describe("collectionView(_:numberOfItemsInSection:)") {

                context("with posts") {
                    beforeEach {
                        // there should be 10 posts
                        // 10 * 3(number of cells for a post w/ 1 region) = 30
                        var posts = [Post]()
                        for index in 1...10 {
                            posts.append(Post.stub(["id": "\(index)"]))
                        }
                        var cellItems = StreamCellItemParser().parse(posts, streamKind: .Friend)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns the correct number of rows") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 30
                    }
                }

                context("with reposts") {
                    beforeEach {
                        // there should be 10 reposts
                        // 10 * 7(number of cells for a repost w/ 2 regions) = 70
                        var posts = [Post]()
                        for index in 1...10 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "repostContent": [TextRegion.stub([:]), TextRegion.stub([:])],
                                "content": [TextRegion.stub([:]), TextRegion.stub([:])]
                                ])
                            )
                        }
                        var cellItems = StreamCellItemParser().parse(posts, streamKind: .Friend)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns the correct number of rows") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 70
                    }
                }

                context("with collapsed and non collapsed posts") {
                    beforeEach {
                        var posts = [Post]()
                        // there should be 5 collapsed and 5 non collapsed
                        // 5 * 5(number of cells for non collapsed w/ 3 regions) = 25
                        // 5 * 3(number of cells for collapsed) = 15
                        // thus the 40
                        for index in 1...10 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "contentWarning": index % 2 == 0 ? "" : "NSFW",
                                "content": [TextRegion.stub([:]), TextRegion.stub([:]), TextRegion.stub([:])]
                                ])
                            )
                        }
                        var cellItems = StreamCellItemParser().parse(posts, streamKind: .Friend)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns the correct number of rows") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 40
                    }
                }
            }

            describe("indexPathForItem(_:)") {
                var postItem: StreamCellItem!
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .Friend)
                    postItem = cellItems[0]
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an indexPath") {
                    expect(subject.indexPathForItem(postItem)).to(beAKindOf(NSIndexPath.self))
                }

                it("returns nil when cell doesn't exist") {
                    let anyItem = StreamCellItem(jsonable: Comment.stub([:]), type: .SeeMoreComments, data: nil, oneColumnCellHeight: 60.0, multiColumnCellHeight: 60.0, isFullWidth: true)
                    expect(subject.indexPathForItem(anyItem)).to(beNil())
                }

                it("returns nil when cell is hidden") {
                    subject.streamFilter = { postItem in return false }
                    expect(subject.indexPathForItem(postItem)).to(beNil())
                }
            }

            describe("postForIndexPath(_:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .Friend)
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
            }

            describe("imageAssetForIndexPath(_:)") {

                beforeEach {
                    let asset = Asset.stub([:])
                    let region = ImageRegion.stub(["asset": asset])
                    let post = Post.stub(["content": [region]])
                    let cellItems = StreamCellItemParser().parse([post], streamKind: .Friend)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an image asset") {
                    expect(subject.imageAssetForIndexPath(NSIndexPath(forItem: 1, inSection: 0))).to(beAKindOf(Asset.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.imageAssetForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.imageAssetForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("commentForIndexPath(_:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Comment.stub([:])], streamKind: .Friend)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns a comment") {
                    expect(subject.commentForIndexPath(indexPath0)).to(beAKindOf(Comment.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.commentForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.commentForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("cellItemsForPost(_:)") {

                beforeEach {
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([Post.stub(["id": "666"])], streamKind: .Friend)
                    let commentCellItems = parser.parse([Comment.stub(["postId": "666"]), Comment.stub(["postId": "666"])], streamKind: .Friend)
                    let otherPostCellItems = parser.parse([Post.stub(["id": "777"])], streamKind: .Friend)
                    let cellItems = postCellItems + commentCellItems + otherPostCellItems
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of StreamCellItems") {
                    var post = subject.postForIndexPath(indexPath0)
                    let items = subject.cellItemsForPost(post!)
                    expect(count(items)) == 3
                }

                it("returns empty array if post not found") {
                    let randomPost: Post = stub(["id": "notfound"])
                    let items = subject.cellItemsForPost(randomPost)
                    expect(count(items)) == 0
                }

                it("does not return cell items for other posts") {
                    var post = subject.postForIndexPath(NSIndexPath(forItem: 9, inSection: 0))
                    let items = subject.cellItemsForPost(post!)
                    expect(count(items)) == 3
                }

            }

            describe("userForIndexPath(_:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([User.stub(["id": "42"])], streamKind: .UserList(endpoint: ElloAPI.UserStream(userParam: "42"), title: "yup"))
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns a user") {
                    expect(subject.userForIndexPath(indexPath0)).to(beAKindOf(User.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.userForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.userForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("commentIndexPathsForPost(_:)") {

                beforeEach {
                    var cellItems = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    // creates 3 cells
                    let post1CellItems = parser.parse([Post.stub(["id": "666"])], streamKind: .Friend)
                    cellItems = post1CellItems
                    // creates 4 cells 2x2
                    let comment1CellItems = parser.parse([Comment.stub(["parentPostId": "666"]), Comment.stub(["parentPostId": "666"])], streamKind: .Friend)
                    cellItems += comment1CellItems
                    // one cell
                    let seeMoreCellItem = StreamCellItem(jsonable: Comment.stub(["parentPostId": "666"]), type: .SeeMoreComments, data: nil, oneColumnCellHeight: 60.0, multiColumnCellHeight: 60.0, isFullWidth: true)
                    cellItems.append(seeMoreCellItem)
                    // creates 3 cells
                    let post2CellItems = parser.parse([Post.stub(["id": "777"])], streamKind: .Friend)
                    cellItems += post2CellItems
                    // creates 2 cells
                    let comment2CellItems = parser.parse([Comment.stub(["parentPostId": "777"])], streamKind: .Friend)
                    cellItems += comment2CellItems
                    // creates 4 cells
                    let post3CellItems = parser.parse([Post.stub(["id": "888", "contentWarning": "NSFW"])], streamKind: .Friend)
                    cellItems += post3CellItems
                    // create 1 cell
                    let createCommentCellItem = StreamCellItem(jsonable: Comment.stub(["parentPostId": "888"]), type: .CreateComment, data: nil, oneColumnCellHeight: StreamCreateCommentCell.Size.Height, multiColumnCellHeight: StreamCreateCommentCell.Size.Height, isFullWidth: true)
                    cellItems.append(createCommentCellItem)
                    // creates 2 cells
                    let comment3CellItems = parser.parse([Comment.stub(["parentPostId": "888"])], streamKind: .Friend)
                    cellItems += comment3CellItems
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of comment index paths") {
                    var post = subject.postForIndexPath(indexPath0)
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(count(indexPaths)) == 5
                    expect(indexPaths[0].item) == 3
                    expect(indexPaths[1].item) == 4
                    expect(indexPaths[2].item) == 5
                    expect(indexPaths[3].item) == 6
                    expect(indexPaths[4].item) == 7
                }

                it("does not return index paths for comments from another post") {
                    var post = subject.postForIndexPath(NSIndexPath(forItem: 8, inSection: 0))
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(count(indexPaths)) == 2
                    expect(indexPaths[0].item) == 11
                    expect(indexPaths[1].item) == 12
                }

                it("returns an array of comment index paths when collapsed") {
                    var post = subject.postForIndexPath(NSIndexPath(forItem: 13, inSection: 0))
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(count(indexPaths)) == 3
                    expect(indexPaths[0].item) == 16
                    expect(indexPaths[1].item) == 17
                    expect(indexPaths[2].item) == 18
                }
            }

            describe("footerIndexPathForPost(_:)") {
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub(["id": "456"])], streamKind: .Friend)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("returns the index path of the footer associated with this post") {
                    var post = subject.postForIndexPath(indexPath0)
                    let indexPath = subject.footerIndexPathForPost(post!)

                    expect(indexPath!.item) == 2
                    expect(subject.visibleCellItems[indexPath!.item].type) == StreamCellType.Footer
                }
            }

           describe("modifyItems(_:change:collectionView:)") {

                context("with comments") {

                    let stubCommentCellItems: (commentsVisible: Bool) -> Void = { (commentsVisible: Bool) in
                        let parser = StreamCellItemParser()
                        let postCellItems = parser.parse([Post.stub(["id": "456"])], streamKind: .Friend)
                        let commentButtonCellItem = [StreamCellItem(
                            jsonable: Comment.stub(["postId": "456"]),
                            type: .CreateComment,
                            data: nil,
                            oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
                            multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
                            isFullWidth: true)
                        ]
                        let commentCellItems = parser.parse([Comment.stub(["postId": "456", "id" : "111"])], streamKind: .Friend)
                        var cellItems = postCellItems
                        if commentsVisible {
                            cellItems = cellItems + commentButtonCellItem + commentCellItems
                        }
                        subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    describe(".Create") {

                        it("inserts the new comment") {
                            stubCommentCellItems(commentsVisible: true)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 6
                            subject.modifyItems(Comment.stub(["id": "new_comment", "postId": "456"]), change: .Create, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 8
                            expect(subject.commentForIndexPath(NSIndexPath(forItem: 4, inSection: 0))!.id) == "new_comment"
                        }

                        it("doesn't insert the new comment") {
                            stubCommentCellItems(commentsVisible: false)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 3
                            subject.modifyItems(Comment.stub(["id": "new_comment", "postId": "456"]), change: .Create, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 3
                        }

                    }

                    describe(".Delete") {

                        it("removes the deleted comment") {
                            stubCommentCellItems(commentsVisible: true)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 6
                            subject.modifyItems(Comment.stub(["id": "111", "postId": "456"]), change: .Delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 4

                        }

                        it("doesn't remove the deleted comment") {
                            stubCommentCellItems(commentsVisible: false)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 3
                            subject.modifyItems(Comment.stub(["id": "111", "postId": "456"]), change: .Delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 3
                        }

                    }
                }

                context("with posts") {

                    beforeEach {
                        var posts = [Post]()
                        for index in 1...5 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "commentsCount" : 5,
                                "content": [TextRegion.stub([:])]
                                ])
                            )
                        }

                        var cellItems = StreamCellItemParser().parse(posts, streamKind: .Friend)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    describe(".Create") {

                        context("StreamKind.Friend") {

                            it("inserts the new post at 0, 0") {
                                subject.streamKind = .Friend
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .Create, collectionView: fakeCollectionView)
                                expect(subject.postForIndexPath(indexPath0)!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 18
                            }

                        }

                        context("StreamKind.Profile") {

                            it("inserts the new post at 1, 0") {
                                subject.streamKind = .Profile(perPage: 10)
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .Create, collectionView: fakeCollectionView)
                                expect(subject.postForIndexPath(indexPath0)!.id) == "1"
                                expect(subject.postForIndexPath(NSIndexPath(forItem: 1, inSection: 0))!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 18
                            }

                        }

                        context("StreamKind.UserStream") {

                            it("inserts the new post at 1, 0") {
                                subject.currentUser = User.stub(["id" : "user-id-here"])
                                subject.streamKind = .UserStream(userParam: "user-id-here")

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .Create, collectionView: fakeCollectionView)

                                expect(subject.postForIndexPath(indexPath0)!.id) == "1"
                                expect(subject.postForIndexPath(NSIndexPath(forItem: 1, inSection: 0))!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 18
                            }

                            it("does not insert a post in other user's profiles") {
                                subject.currentUser = User.stub(["id" : "not-current-user-id-here"])
                                subject.streamKind = .UserStream(userParam: "user-id-here")

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .Create, collectionView: fakeCollectionView)

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                            }
                        }

                        context("StreamKind.Noise") {

                            it("does not insert a post") {
                                subject.streamKind = .Noise

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .Create, collectionView: fakeCollectionView)

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                            }
                        }

                        context("StreamKind.Loves") {

                            it("adds the newly loved post") {
                                subject.streamKind = StreamKind.Loves(userId: "fake-id")
                                var post: Post = stub(["id": "post1", "authorId" : "user1"])
                                var love: Love = stub(["id": "love1", "postId": "post1"])
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15

                                subject.modifyItems(love, change: .Create, collectionView: fakeCollectionView)

                                expect(subject.postForIndexPath(indexPath0)!.id) == "post1"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 18
                            }
                        }
                    }

                    describe(".Delete") {

                        beforeEach {
                            subject.streamKind = .Friend
                        }

                        it("removes the deleted post") {
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                            subject.modifyItems(Post.stub(["id": "1"]), change: .Delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 12
                        }

                        it("doesn't remove the deleted comment") {
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                            subject.modifyItems(Post.stub(["id": "not-present"]), change: .Delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                        }
                    }

                    describe(".Update") {

                        beforeEach {
                            subject.streamKind = .Friend
                        }

                        it("updates the updated post") {
                            expect(subject.postForIndexPath(NSIndexPath(forItem: 3, inSection: 0))!.commentsCount) == 5
                            subject.modifyItems(Post.stub(["id": "2", "commentsCount" : 9]), change: .Update, collectionView: fakeCollectionView)
                            expect(subject.postForIndexPath(NSIndexPath(forItem: 3, inSection: 0))!.commentsCount) == 9
                        }

                        it("doesn't update the updated post") {
                            subject.modifyItems(Post.stub(["id": "not-present", "commentsCount" : 88]), change: .Update, collectionView: fakeCollectionView)

                            for (index, item) in enumerate(subject.streamCellItems) {
                                expect((item.jsonable as! Post).commentsCount) == 5
                            }
                        }

                        context("StreamKind.Loves") {

                            beforeEach {
                                subject.streamKind = StreamKind.Loves(userId: "fake-id")
                            }

                            it("removes the unloved post") {
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 15
                                subject.modifyItems(Post.stub(["id": "2", "commentsCount" : 9, "loved" : false]), change: .Update, collectionView: fakeCollectionView)
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 12
                            }
                        }
                    }
                }
            }

            describe("modifyUserRelationshipItems(_:collectionView:)") {

                let stubCellItems: (streamKind: StreamKind) -> Void = { streamKind in
                    var user1: User = stub(["id": "user1"])
                    var post1: Post = stub(["id": "post1", "authorId" : "user1"])
                    var post1Comment1: Comment = stub([
                        "parentPost": post1,
                        "id" : "comment1",
                        "authorId": "user1"
                    ])
                    var post1Comment2: Comment = stub([
                        "parentPost": post1,
                        "id" : "comment2",
                        "authorId": "user2"
                    ])
                    let parser = StreamCellItemParser()
                    let userCellItems = parser.parse([user1], streamKind: streamKind)
                    let post1CellItems = parser.parse([post1], streamKind: streamKind)
                    let post1CommentCellItems = parser.parse([post1Comment1, post1Comment2], streamKind: streamKind)
                    var cellItems = userCellItems + post1CellItems + post1CommentCellItems
                    subject.streamKind = streamKind
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                describe("blocking a user") {

                    context("blocked user is the post author") {
                        it("removes blocked user, their post and all comments on that post") {
                            stubCellItems(streamKind: StreamKind.UserList(endpoint: ElloAPI.FriendStream, title: "some title"))
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 8
                            subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.Block.rawValue]), collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 0
                        }
                    }

                    context("blocked user is not the post author") {
                        it("removes blocked user's comments") {
                            stubCellItems(streamKind: StreamKind.UserList(endpoint: ElloAPI.FriendStream, title: "some title"))
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 8
                            subject.modifyUserRelationshipItems(User.stub(["id": "user2", "relationshipPriority": RelationshipPriority.Block.rawValue]), collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 6
                        }
                    }

                    it("does not remove cells tied to other users") {
                        stubCellItems(streamKind: StreamKind.UserList(endpoint: ElloAPI.FriendStream, title: "some title"))
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 8
                        subject.modifyUserRelationshipItems(User.stub(["id": "unrelated-user", "relationshipPriority": RelationshipPriority.Block.rawValue]), collectionView: fakeCollectionView)
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 8
                    }

                }

                describe("friending/noising/inactivating a user") {

                    it("updates posts from that user") {
                        stubCellItems(streamKind: StreamKind.UserList(endpoint: ElloAPI.FriendStream, title: "some title"))
                        var user1 = subject.userForIndexPath(indexPath0)
                        expect(user1!.followersCount) == "stub-user-followers-count"
                        expect(user1!.relationshipPriority.rawValue) == RelationshipPriority.None.rawValue
                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "followersCount": "2", "followingCount": 2, "relationshipPriority": RelationshipPriority.Friend.rawValue]), collectionView: fakeCollectionView)
                        user1 = subject.userForIndexPath(indexPath0)
                        expect(user1!.followersCount) == "2"
                        expect(user1!.relationshipPriority.rawValue) == RelationshipPriority.Friend.rawValue
                    }

                    xit("updates comments from that user") {
                        // comments are not yet affected by User.RelationshipPriority changes
                        // left intentionally empty for documentation
                    }

                    it("updates cells tied to that user") {

                    }
                }

                describe("muting a user") {

                    beforeEach {
                        var streamKind: StreamKind = .Notifications(category: nil)
                        var user1: User = stub(["id": "user1"])
                        var post1: Post = stub(["id": "post1", "authorId" : "other-user"])
                        var activity1: Activity = stub(["id": "activity1", "subject" : user1])
                        var activity2: Activity = stub(["id": "activity2", "subject" : post1])
                        let parser = StreamCellItemParser()
                        let notificationCellItems = parser.parse([activity1, activity2], streamKind: streamKind)
                        subject.streamKind = streamKind
                        subject.appendUnsizedCellItems(notificationCellItems, withWidth: webView.frame.width) { cellCount in
                            vc.collectionView.dataSource = subject
                            vc.collectionView.reloadData()
                        }
                    }

                    it("clears out notifications from that user when on notifications") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 2
                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.Mute.rawValue]), collectionView: fakeCollectionView)
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 1
                    }

                    it("does not clear out content from that user when elsewhere") {

                    }
                }

            }

            describe("modifyUserSettingsItems(_:collectionView:)") {

                let stubCellItems: (streamKind: StreamKind) -> Void = { streamKind in
                    var user1: User = stub(["id": "user1", "username": "sweet"])
                    var user2: User = stub(["id": "user2", "username": "unsweet"])
                    let userCellItems = StreamCellItemParser().parse([user1, user2], streamKind: streamKind)
                    var cellItems = userCellItems
                    subject.streamKind = streamKind
                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
                        vc.collectionView.dataSource = subject
                        vc.collectionView.reloadData()
                    }
                }

                it("modifies a user when it is the currentUser") {
                    it("removes blocked user, their post and all comments on that post") {
                        stubCellItems(streamKind: StreamKind.UserList(endpoint: ElloAPI.FriendStream, title: "some title"))
                        expect(subject.userForIndexPath(indexPath0)!.username) == "sweet"
                        subject.modifyUserSettingsItems(User.stub(["id": "user1", "username": "sweetness"]), collectionView: fakeCollectionView)
                        expect(subject.userForIndexPath(indexPath0)!.username) == "sweetness"
                    }
                }
            }

//            describe("createCommentIndexPathForPost(_:)") {
//                beforeEach {
//                    var items = [StreamCellItem]()
//                    let parser = StreamCellItemParser()
//                    items += parser.parse([Post.stub(["id": "666"])], streamKind: .Friend)
//                    items += parser.parse([Comment.stub(["postId": "666"]), Comment.stub(["postId": "666"])], streamKind: .Friend)
//                    items.append(StreamCellItem(jsonable: Comment.stub([:]),
//                        type: .CreateComment,
//                        data: nil,
//                        oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
//                        multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
//                        isFullWidth: true))
//                    items += parser.parse([Post.stub(["id": "777"])], streamKind: .Friend)
//                    items += parser.parse([Comment.stub(["postId": "777"])], streamKind: .Friend)
//                    subject.appendUnsizedCellItems(items, withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("points to a create-comment-item") {
//                    let post = subject.postForIndexPath(indexPath0)
//                    if let path = subject.createCommentIndexPathForPost(post!) {
//                        if let item = subject.visibleStreamCellItem(at: path) {
//                            expect(item.type).to(equal(StreamCellType.CreateComment))
//                        }
//                        else {
//                            fail("no streamCellItem found")
//                        }
//                    }
//                    else {
//                        fail("no createCommentIndexPath found")
//                    }
//                }
//
//            }

//            xdescribe("-removeCommentsForPost:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    let cellItems = ModelHelper.cellsForPostWithComments("123")
//                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                    }
//                }
//
//                it("removes comment index paths") {
//                    var post = subject.postForIndexPath(indexPath0)
//                    let indexPaths = subject.removeCommentsForPost(post!)
//
//                    expect(count(indexPaths)) == 5
//                    expect(indexPaths[0].item) == 8
//                    expect(indexPaths[1].item) == 9
//                    expect(indexPaths[2].item) == 10
//                    expect(indexPaths[3].item) == 11
//                    expect(indexPaths[4].item) == 12
//                }
//
//            }
//
//            xdescribe("-updateHeightForIndexPath:") {
//
//                it("updates the height of an existing StreamCellItem") {
//                    subject.updateHeightForIndexPath(indexPath0, height: 256)
//
//                    let cellItem = subject.visibleStreamCellItem(at: NSIndexPath(forRow: 0, inSection: 0))
//                    expect(cellItem!.oneColumnCellHeight) == 266
//                    expect(cellItem!.multiColumnCellHeight) == 266
//                }
//
//                it("handles non-existent index paths") {
//                    expect(subject.updateHeightForIndexPath(indexPathOutOfBounds, height: 256))
//                        .notTo(raiseException())
//                }
//
//                it("handles invalid section") {
//                    expect(subject.updateHeightForIndexPath(indexPathInvalidSection, height: 256))
//                        .notTo(raiseException())
//                }
//            }
//
//            xdescribe("-heightForIndexPath:numberOfColumns") {
//                // Need to test this but the sell sizers are not synchronous and are a pain in the ass
//                xit("returns the correct height") {}
//
//                it("returns 0 when out of bounds") {
//                    expect(subject.heightForIndexPath(indexPathOutOfBounds, numberOfColumns: 0)) == 0
//                }
//
//                it("returns 0 when invalid section") {
//                    expect(subject.heightForIndexPath(indexPathInvalidSection, numberOfColumns: 0)) == 0
//                }
//            }
//
//            xdescribe("-removeAllCellItems") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("sets the number of visible cell items to 0") {
//                    expect(count(subject.visibleCellItems)) > 0
//                    subject.removeAllCellItems()
//                    expect(count(subject.visibleCellItems)) == 0
//                }
//
//                it("sets the number of cell items to 0") {
//                    expect(count(subject.streamCellItems)) > 0
//                    subject.removeAllCellItems()
//                    expect(count(subject.streamCellItems)) == 0
//                }
//            }
//
//            xdescribe("-removeCellItemsBelow:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("removes items below the supplied index") {
//                    expect(count(subject.visibleCellItems)) == 9
//                    subject.removeCellItemsBelow(5)
//
//                    expect(count(subject.visibleCellItems)) == 5
//                }
//            }
//
//            xdescribe("-visibleStreamCellItem:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("returns the correct stream cell item") {
//                    let item = subject.visibleStreamCellItem(at: NSIndexPath(forItem: 4, inSection:0))
//
//                    expect(item?.type.name) == "StreamHeaderCell"
//                }
//
//                it("returns nil if indexpath does not exist") {
//                    let item = subject.visibleStreamCellItem(at: NSIndexPath(forItem: 50, inSection:0))
//
//                    expect(item).to(beNil())
//                }
//
//            }
//
//            xdescribe("-toggleCollapsedForIndexPath:") {
//
//                beforeEach {
//                    subject.removeAllCellItems()
//                    let post: Post = stub(["collapsed" : true])
//                    subject.removeAllCellItems()
//                    let toggleCellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//                    let imageRegion: ImageRegion = stub([:])
//                    let imageCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//
//                    let anotherPost: Post = stub(["collapsed" : true])
//                    let anotherToggleCellItem = StreamCellItem(jsonable: anotherPost, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//                    let anotherImageRegion: ImageRegion = stub([:])
//                    let anotherImageCellItem = StreamCellItem(jsonable: anotherPost, type: .Image, data: anotherImageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//
//                    subject.appendUnsizedCellItems([toggleCellItem, imageCellItem, anotherToggleCellItem, anotherImageCellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("toggles collapsed on the post at an indexPath") {
//                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
//                    var post = subject.postForIndexPath(indexPath)!
//
//                    expect(post.collapsed).to(beTrue())
//
//                    subject.toggleCollapsedForIndexPath(indexPath)
//
//                    expect(post.collapsed).to(beFalse())
//                }
//
//                it("does not toggle collapsed on other posts") {
//                    let indexPathToToggle = NSIndexPath(forItem: 1, inSection: 0)
//                    var postToToggle = subject.postForIndexPath(indexPathToToggle)!
//
//                    let indexPathNotToToggle = NSIndexPath(forItem: 0, inSection: 0)
//                    var postNotToToggle = subject.postForIndexPath(indexPathNotToToggle)!
//
//                    expect(postToToggle.collapsed).to(beTrue())
//                    expect(postNotToToggle.collapsed).to(beTrue())
//
//                    subject.toggleCollapsedForIndexPath(indexPathToToggle)
//
//                    expect(postToToggle.collapsed).to(beFalse())
//                    expect(postNotToToggle.collapsed).to(beTrue())
//                }
//            }
//
//            xdescribe("-isFullWidthAtIndexPath:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
//                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                xit("returns true for ProfileHeaderCells") {
//                }
//
//                xit("returns false for all other cells") {
//                }
//
//                it("returns true when out of bounds") {
//                    expect(subject.isFullWidthAtIndexPath(indexPathOutOfBounds)) == true
//                }
//
//                it("returns true when invalid section") {
//                    expect(subject.isFullWidthAtIndexPath(indexPathInvalidSection)) == true
//                }
//
//            }
//
//            xdescribe("-maintainAspectRatioForItemAtIndexPath:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
//                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("returns false") {
//                    let cellCount = subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)
//
//                    for index in 0..<cellCount {
//                        expect(subject.maintainAspectRatioForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))) == false
//                    }
//                }
//            }
//
//            xdescribe("-groupForIndexPath:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    let cellItems = ModelHelper.cellsForTwoPostsWithComments()
//                    subject.appendUnsizedCellItems(cellItems, withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                xit("returns the same value for a post and it's comments") {
//                    var groupIndexPaths = [NSIndexPath]()
//                    for index in 0...10 {
//                        groupIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
//                    }
//
//                    for indexPath in groupIndexPaths {
//                        expect(subject.groupForIndexPath(indexPath)) == "555"
//                    }
//                }
//
//                it("does not return the same value for two different posts") {
//                    let firstPostIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//                    let secondPostIndexPath = NSIndexPath(forItem: 12, inSection: 0)
//
//                    let firstGroupId = subject.groupForIndexPath(firstPostIndexPath)
//                    let secondGroupId = subject.groupForIndexPath(secondPostIndexPath)
//
//                    expect(firstGroupId) != secondGroupId
//                }
//
//                it("returns '0' if indexPath out of bounds") {
//                    expect(subject.groupForIndexPath(indexPathOutOfBounds)) == "0"
//                }
//
//                it("returns '0' if invalid section") {
//                    expect(subject.groupForIndexPath(indexPathInvalidSection)) == "0"
//                }
//
//                it("returns '0' if StreamCellItem's jsonable is not Authorable") {
//
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    let nonAuthorable: Asset = stub(["id": "123"])
//
//                    let cellItem = StreamCellItem(jsonable: nonAuthorable, type: .Image, data: nil, oneColumnCellHeight: 0, multiColumnCellHeight: 0, isFullWidth: false)
//
//                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//
//                    expect(subject.groupForIndexPath(indexPath0)) == "0"
//                }
//            }
//
//            xdescribe("-insertUnsizedCellItems:withWidth:startingIndexPath:completion:") {
//
//                beforeEach {
//                    subject.removeAllCellItems()
//                    let post: Post = stub(["collapsed" : true])
//                    subject.removeAllCellItems()
//                    let toggleCellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//                    let imageRegion: ImageRegion = stub([:])
//                    let imageCellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//
//                    let anotherPost: Post = stub(["collapsed" : false])
//                    let anotherImageRegion: ImageRegion = stub([:])
//                    let anotherImageCellItem = StreamCellItem(jsonable: anotherPost, type: .Image, data: anotherImageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//
//                    subject.appendUnsizedCellItems([toggleCellItem, imageCellItem, anotherImageCellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                it("inserts the new cellitems in the correct position") {
//                    let comment = ModelHelper.stubComment("456", contentCount: 1, parentPost: Post.stub([:]))
//                    let createCommentCellItem = StreamCellItem(jsonable: comment, type: .CreateComment, data: nil, oneColumnCellHeight: StreamCreateCommentCell.Size.Height, multiColumnCellHeight: StreamCreateCommentCell.Size.Height, isFullWidth: true)
//
//                    expect(count(subject.visibleCellItems)) == 1
//
//                    let startingIndexPath = NSIndexPath(forItem: 1, inSection: 0)
//
//                    var expectedIndexPaths = [NSIndexPath]()
//                    subject.insertUnsizedCellItems([createCommentCellItem], withWidth: 10.0, startingIndexPath: startingIndexPath ){ (indexPaths) in
//                        expectedIndexPaths = indexPaths
//                    }
//
//                    let insertedCellItem = subject.visibleCellItems[1]
//
//                    expect(count(subject.visibleCellItems)) == 2
//
//                    expect(insertedCellItem.type.name) == "StreamCreateCommentCell"
//                }
//            }
//
//            xdescribe("-collectionView:cellForItemAtIndexPath:") {
//
//                beforeEach {
//                    subject = StreamDataSource(streamKind: .Friend,
//                        textSizeCalculator: textSizeCalculator,
//                        notificationSizeCalculator: notificationSizeCalculator,
//                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
//
//                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//                }
//
//                describe("with posts") {
//                    it("returns a StreamHeaderCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
//                    }
//
//                    it("returns a StreamTextCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 1, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
//                    }
//
//                    it("returns a StreamFooterCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 2, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
//                    }
//                }
//
//                describe("with comments") {
//                    it("returns a StreamHeaderCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamFooterCell.self))
//                    }
//
//                    it("returns a StreamTextCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 4, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
//                    }
//                }
//
//                describe("with users") {
//                    it("returns a ProfileHeaderCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 5, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
//                    }
//
//                    it("returns a UserListItemCell") {
//                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 6, inSection: 0))
//                        expect(cell).to(beAnInstanceOf(ProfileHeaderCell.self))
//                    }
//                }
//
//                it("returns a NotificationCell") {
//                    let notification: Notification = stub([:])
//                    subject.removeAllCellItems()
//                    let cellItem = StreamCellItem(jsonable: notification, type: .Notification, data: nil, oneColumnCellHeight: 60.0, multiColumnCellHeight: StreamCreateCommentCell.Size.Height, isFullWidth: true)
//                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//
//                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                    expect(cell).to(beAnInstanceOf(NotificationCell.self))
//                }
//
//                it("returns a StreamImageCell") {
//                    let post: Post = stub([:])
//                    let imageRegion: ImageRegion = stub([:])
//                    subject.removeAllCellItems()
//                    let cellItem = StreamCellItem(jsonable: post, type: .Image, data: imageRegion, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//
//                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                    expect(cell).to(beAnInstanceOf(StreamImageCell.self))
//                }
//
//                it("returns a StreamToggleCell") {
//                    // Xcode is unable to compile the specs with all the cell types that are generated by the "allCellTypes()" helper in Model Helper
//                    let post: Post = stub([:])
//                    subject.removeAllCellItems()
//                    let cellItem = StreamCellItem(jsonable: post, type: .Toggle, data: nil, oneColumnCellHeight: 5.0, multiColumnCellHeight: 5.0, isFullWidth: false)
//                    subject.appendUnsizedCellItems([cellItem], withWidth: webView.frame.width) { cellCount in
//                        vc.collectionView.dataSource = subject
//                        vc.collectionView.reloadData()
//                    }
//
//                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                    expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
//                }
//            }
        }
    }
}
