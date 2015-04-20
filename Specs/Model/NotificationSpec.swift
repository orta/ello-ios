//
//  NotificationSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class NotificationSpec: QuickSpec {
    override func spec() {
        it("converts activities to Notifications") {
            var user: User = stub(["username": "foo"])
            var post: Post = stub([
                "id": "123",
                "createdAt": NSDate(),
                "href": "",
                "token": "not used",
                "contentWarning": "null",
                "allowComments": true,
                "author": user,
                "summary": [TextRegion(content: "LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT")]
            ])
            var createdAtDate = NSDate()
            var activity: Activity = stub(["subject": post, "createdAt": createdAtDate, "id": "123", "subjectType": Activity.SubjectType.Post.rawValue, "kind": Activity.Kind.RepostNotification.rawValue])
            var notification = Notification(activity: activity)

            expect(notification.activity.id).to(equal("123"))
            expect(notification.author!.id).to(equal(user.id))
            expect(notification.createdAt).to(equal(createdAtDate))
            expect(notification.groupId).to(equal("123"))
            expect(notification.activity.kind).to(equal(Activity.Kind.RepostNotification))
            expect(notification.activity.subjectType).to(equal(Activity.SubjectType.Post))
            expect(notification.subject!.id).to(equal(post.id))

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

                    let author: User = stub(["id" : "author-id"])

                    let activity: Activity = stub([
                        "subject" : author,
                        "createdAt" : expectedCreatedAt,
                        "id" : "test-notication-id",
                        "kind" : "noise_post",
                        "subjectType" : "Post"
                    ])
                    let notification: Notification = stub(["activity": activity])

                    NSKeyedArchiver.archiveRootObject(notification, toFile: filePath)
                    let unArchivedNotification = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Notification

                    expect(unArchivedNotification).toNot(beNil())
                    expect(unArchivedNotification.version) == 1

                    let unarchivedAuthor = unArchivedNotification.author!

                    expect(unarchivedAuthor.id) == "author-id"

                    expect(unArchivedNotification.createdAt) == expectedCreatedAt
                    expect(unArchivedNotification.activity.id) == "test-notication-id"
                    expect(unArchivedNotification.activity.kind.rawValue) == Activity.Kind.NoisePost.rawValue
                    expect(unArchivedNotification.activity.subjectType.rawValue) == Activity.SubjectType.Post.rawValue
                }
            }
        }
    }
}

