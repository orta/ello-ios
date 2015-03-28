//
//  NotificationSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class NotificationSpec: QuickSpec {
    override func spec() {
        it("converts activities to Notifications") {
            var user = User.fakeCurrentUser("foo")
            var post = Post(
                assets: nil,
                author: user,
                collapsed: false,
                commentsCount: 0,
                content: [TextRegion(content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit")],
                createdAt: NSDate(),
                href: "",
                postId: "123",
                repostsCount: 0,
                summary: [TextRegion(content: "LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT")],
                token: "not used",
                viewsCount: 0,
                comments: []
            )
            var createdAtDate = NSDate()
            var activity = Activity(activityId: "123", kind: .RepostNotification, subjectType: .Post, subject: post, createdAt: createdAtDate)
            var notification = Notification(activity: activity)

            expect(notification.notificationId).to(equal("123"))
            expect(notification.author!).to(equal(user))
            expect(notification.createdAt).to(equal(createdAtDate))
            expect(notification.groupId).to(equal("123"))
            expect(notification.kind).to(equal(Activity.Kind.RepostNotification))
            expect(notification.subjectType).to(equal(Activity.SubjectType.Post))
            expect(notification.subject as? Post).to(equal(post))

            expect(notification.attributedTitle.string).to(equal("@foo reposted your post."))
            expect(notification.textRegion!.content).to(equal("LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT"))
            expect(notification.imageRegion).to(beNil())
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("NotificationSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let notification: Notification = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(notification, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()

                    let author: User = stub(["userId" : "author-id"])

                    let notification: Notification = stub([
                        "author" : author,
                        "createdAt" : expectedCreatedAt,
                        "notificationId" : "test-notication-id",
                        "kind" : "noise_post",
                        "subjectType" : "Post"
                    ])

                    NSKeyedArchiver.archiveRootObject(notification, toFile: filePath)
                    let unArchivedNotification = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Notification

                    expect(unArchivedNotification).toNot(beNil())
                    expect(unArchivedNotification.version) == 1

                    let unarchivedAuthor = unArchivedNotification.author!

                    expect(unarchivedAuthor.userId) == "author-id"

                    expect(unArchivedNotification.createdAt) == expectedCreatedAt
                    expect(unArchivedNotification.notificationId) == "test-notication-id"
                    expect(unArchivedNotification.kind.rawValue) == Activity.Kind.NoisePost.rawValue
                    expect(unArchivedNotification.subjectType.rawValue) == Activity.SubjectType.Post.rawValue
                }
            }
        }
    }
}