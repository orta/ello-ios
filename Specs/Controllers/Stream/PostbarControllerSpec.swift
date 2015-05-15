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
        let controller = StreamViewController.instantiateFromStoryboard()
        var streamKind: StreamKind = .Friend
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

            subject.currentUser = User.stub(["id": "user500"])
        }

        describe("PostbarController") {

            describe("loveButtonTapped(_:)") {

                let stubCellItems: (loved: Bool) -> Void = { loved in
                    var user: User = stub(["id": "user1"])
                    var post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                        "loveCount" : 5,
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
                        var loveCount = 0
                        var observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            loveCount = post.loveCount!
                        }
                        subject.lovesButtonTapped(NSIndexPath(forItem: 2, inSection: 0))
                        observer.removeObserver()

                        expect(loveCount) == 6
                    }
                }

                context("post has already been loved") {

                    it("unloves the post") {
                        stubCellItems(loved: true)
                        var loveCount = 0
                        var observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            loveCount = post.loveCount!
                        }
                        subject.lovesButtonTapped(NSIndexPath(forItem: 2, inSection: 0))
                        observer.removeObserver()

                        expect(loveCount) == 4
                    }
                }
            }
        }
    }
}
