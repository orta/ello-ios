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

    override func spec() {
        var subject: PostbarController!
        let currentUser: User = User.stub([
            "id": "user500",
            "lovesCount": 5,
            ])
        let controller = StreamViewController.instantiateFromStoryboard()
        let streamKind: StreamKind = .Following
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator(webView: UIWebView(frame: webView.frame))
        let imageSizeCalculator = StreamImageCellSizeCalculator()

        beforeEach {
            controller.dataSource =
                StreamDataSource(streamKind: streamKind,
                    textSizeCalculator: textSizeCalculator,
                    notificationSizeCalculator: notificationSizeCalculator,
                    profileHeaderSizeCalculator: profileHeaderSizeCalculator,
                    imageSizeCalculator: imageSizeCalculator
            )
            controller.collectionView.dataSource = controller.dataSource

            self.showController(controller)
            controller.streamKind = streamKind

            subject = PostbarController(collectionView: controller.collectionView, dataSource: controller.dataSource, presentingController: controller)
            subject.currentUser = currentUser
        }

        describe("PostbarController") {

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
