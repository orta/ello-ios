//
//  StreamHeaderCellPresenterSpec.swift
//  Ello
//
//  Created by Colin Gray on 10/27/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class StreamHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("StreamHeaderCellPresenter") {
            let currentUser: User = stub(["username": "ello"])
            let textRegion: TextRegion = stub(["content" : "I am your comment's content"])
            let content = [textRegion]

            var cell: StreamHeaderCell!
            var item: StreamCellItem!

            context("when item is a Post Header") {
                beforeEach {
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "createdAt": NSDate(timeIntervalSinceNow: -1000),
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .Header)
                }

                it("starts out closed") {
                    cell.scrollView.contentOffset = CGPoint(x: 20, y: 0)
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.scrollView.contentOffset) == CGPointZero
                }
                it("sets the index path") {
                    cell.indexPath = NSIndexPath(forItem: 1, inSection: 1)
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.indexPath) == NSIndexPath(forItem: 0, inSection: 0)
                }
                it("ownPost should be false") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.ownPost) == false
                }
                it("ownComment should be false") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.ownComment) == false
                }
                it("sets streamKind") {
                    cell.streamKind = StreamKind.Starred
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.streamKind?.name) == StreamKind.Following.name
                }
                it("sets scrollView.scrollEnabled") {
                    cell.scrollView.scrollEnabled = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.scrollView.scrollEnabled) == false
                }
                it("sets chevronHidden") {
                    cell.chevronHidden = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.chevronHidden) == true
                }
                it("sets goToPostView.hidden") {
                    cell.goToPostView.hidden = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.goToPostView.hidden) == false
                }
                it("sets canReply") {
                    cell.canReply = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.canReply) == false
                }
                it("sets timeStamp") {
                    cell.timeStamp = ""
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.timeStamp) == "17m"
                }
                it("sets usernameButton title") {
                    cell.usernameButton.setTitle("", forState: .Normal)
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.usernameButton.currentTitle) == "@ello"
                }
                it("hides repostAuthor") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.repostedByLabel.hidden) == true
                    expect(cell.repostIconView.hidden) == true
                }

                context("gridLayout streamKind") {
                    it("sets isGridLayout") {
                        cell.isGridLayout = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Starred, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.isGridLayout) == true
                    }

                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Starred, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 30.0
                    }
                }

                context("not-gridLayout streamKind") {
                    it("sets isGridLayout") {
                        cell.isGridLayout = true
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.isGridLayout) == false
                    }

                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 60.0
                    }
                }
            }

            context("when item is a Post Header with repostAuthor") {
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.Starred.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .Header)
                }
                it("sets relationshipControl properties") {
                    cell.relationshipControl.userId = ""
                    cell.relationshipControl.userAtName = ""
                    cell.relationshipControl.relationshipPriority = RelationshipPriority.Null
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.relationshipControl.userId) == "reposterId"
                    expect(cell.relationshipControl.userAtName) == "@reposter"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.Starred
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }
                it("shows author and repostAuthor") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.repostedByLabel.text) == "by @ello"
                    expect(cell.repostedByLabel.hidden) == false
                    expect(cell.repostIconView.hidden) == false
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind") {
                beforeEach {
                    let author: User = stub([
                        "id": "authorId",
                        "username": "author",
                        "relationshipPriority": RelationshipPriority.Following.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": author,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .Header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .PostDetail(postParam: "768"), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.relationshipControl.userId) == "authorId"
                    expect(cell.relationshipControl.userAtName) == "@author"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.Following
                }
            }

            context("when item is a Post Header with repostAuthor and PostDetail streamKind") {
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.Starred.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .Header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .PostDetail(postParam: "768"), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.relationshipControl.userId) == "reposterId"
                    expect(cell.relationshipControl.userAtName) == "@reposter"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.Starred
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind, but currentUser is the author") {
                beforeEach {
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .Header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .PostDetail(postParam: "768"), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }
            }

            context("when item is a CommentHeader") {
                context("when currentUser is not the author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                        ])
                        let comment: Comment = stub([
                            "id" : "362",
                            "parentPost" : post,
                            "content" : content
                        ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .CommentHeader)
                    }
                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 30.0
                    }
                    it("sets scrollView.scrollEnabled") {
                        cell.scrollView.scrollEnabled = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.scrollView.scrollEnabled) == true
                    }
                    it("sets chevronHidden") {
                        cell.chevronHidden = true
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.chevronHidden) == false
                    }
                    it("sets goToPostView.hidden") {
                        cell.goToPostView.hidden = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.goToPostView.hidden) == true
                    }
                    it("sets canReply") {
                        cell.canReply = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.canReply) == true
                    }
                    it("ownPost should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownPost) == false
                    }
                    it("ownComment should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownComment) == false
                    }
                }
                context("when currentUser is the post author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "author": currentUser,
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                            ])
                        let comment: Comment = stub([
                            "id" : "362",
                            "parentPost" : post,
                            "content" : content
                            ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .CommentHeader)
                    }
                    it("ownPost should be true") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownPost) == true
                    }
                    it("ownComment should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownComment) == false
                    }
                }
                context("when currentUser is the comment author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                            ])
                        let comment: Comment = stub([
                            "id" : "362",
                            "author": currentUser,
                            "parentPost" : post,
                            "content" : content
                            ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .CommentHeader)
                    }
                    it("ownPost should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownPost) == false
                    }
                    it("ownComment should be true") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: currentUser)
                        expect(cell.ownComment) == true
                    }
                }
            }
        }
    }
}
