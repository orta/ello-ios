//
//  PostbarControllerSpec.swift
//  Ello
//
//  Created by Sean on 5/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class PostbarControllerSpec: QuickSpec {
    class ReplyAllCreatePostDelegate: CreatePostDelegate {
        var post: Post?
        var comment: Comment?
        var text: String?

        func createPost(text text: String?, fromController: UIViewController) {
            self.text = text
        }
        func createComment(post: Post, text: String?, fromController: UIViewController) {
            self.post = post
            self.text = text
        }
        func editComment(comment: ElloComment, fromController: UIViewController) {
            self.comment = comment
        }
        func editPost(post: Post, fromController: UIViewController) {
            self.post = post
        }
    }

    override func spec() {
        var subject: PostbarController!
        let currentUser: User = User.stub([
            "id": "user500",
            "lovesCount": 5,
            ])
        var controller: StreamViewController!
        let streamKind: StreamKind = .Following
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let imageSizeCalculator = StreamImageCellSizeCalculator()

        beforeEach {
            controller = StreamViewController.instantiateFromStoryboard()
            controller.dataSource =
                StreamDataSource(streamKind: streamKind,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator,
                    profileHeaderSizeCalculator: profileHeaderSizeCalculator,
                    imageSizeCalculator: imageSizeCalculator
            )
            controller.collectionView.dataSource = controller.dataSource
            controller.streamKind = streamKind

            showController(controller)

            subject = PostbarController(collectionView: controller.collectionView, dataSource: controller.dataSource, presentingController: controller)
            subject.currentUser = currentUser
        }

        describe("PostbarController") {
            describe("replyToAllButtonTapped(_:)") {
                var delegate: ReplyAllCreatePostDelegate!

                beforeEach {
                    let post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                    ])
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([post], streamKind: streamKind)
                    delegate = ReplyAllCreatePostDelegate()
                    controller.createPostDelegate = delegate
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.dataSource = controller.dataSource
                        controller.collectionView.reloadData()
                    }
                }
                context("tapping replyToAll") {
                    it("opens an OmnibarViewController with usernames set") {
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        controller.replyToAllButtonTapped(indexPath)
                        expect(delegate.text) == "@user1 @user2 "
                    }
                }
            }

            describe("loveButtonTapped(_:)") {

                let stubCellItems: (loved: Bool) -> Void = { loved in
                    let post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                        "lovesCount" : 5,
                        "loved" : loved
                    ])
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([post], streamKind: streamKind)
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.dataSource = controller.dataSource
                        controller.collectionView.reloadData()
                    }
                }

                context("post has not been loved") {
                    it("loves the post") {
                        stubCellItems(loved: false)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == 6
                        expect(contentChange) == .Loved
                    }

                    it("increases currentUser lovesCount") {
                        stubCellItems(loved: false)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount + 1
                    }
                }

                context("post has already been loved") {
                    it("unloves the post") {
                        stubCellItems(loved: true)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == 4
                        expect(contentChange) == .Loved
                    }

                    it("decreases currentUser lovesCount") {
                        stubCellItems(loved: true)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount - 1
                    }
                }
            }
        }
    }
}
