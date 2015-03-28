//
//  ActivitySpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class ActivitySpec: QuickSpec {
    override func spec() {
        it("converts Post activities from JSON") {
            let parsedActivity = stubbedJSONData("activity-own-post", "activity")
            let activity = Activity.fromJSON(parsedActivity) as! Activity

            var createdAtString = "2014-06-03T00:00:00.000Z"
            var createdAt:NSDate = createdAtString.toNSDate()!
            
            expect(activity.subjectType) == Activity.SubjectType.Post
            expect(activity.activityId) == createdAtString
            expect(activity.kind) == Activity.Kind.OwnPost
            expect(activity.createdAt) == createdAt

            let post = activity.subject as! Post
            var postCreatedAt:NSDate = "2014-12-23T22:27:47.341Z".toNSDate()!
            expect(post.createdAt) == postCreatedAt

            let postContent0:TextRegion = post.content![0] as! TextRegion
            expect(postContent0.kind) == RegionKind.Text.rawValue
            expect(postContent0.content) == "yo mang"
            
            expect(post.token) == "KVNldSWCvfPkjsbWcvB4mA"
            expect(post.postId) == "598"
            
            let postAuthor = post.author!
            expect(postAuthor.userId) == "42"
            expect(postAuthor.username) == "archer"
            expect(postAuthor.name) == "Sterling"
            expect(postAuthor.experimentalFeatures) == false
            expect(postAuthor.relationshipPriority) == Relationship.Me
            expect(postAuthor.href) == "/api/edge/users/42"
            expect(postAuthor.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/420/large_pam.png"

            let imageRegion:ImageRegion = post.content![1] as! ImageRegion

            expect(imageRegion.asset!.xxhdpi).notTo(beNil())
            expect(imageRegion.asset!.xxhdpi!.width) == 2560
            expect(imageRegion.asset!.xxhdpi!.height) == 1094
            expect(imageRegion.asset!.xxhdpi!.size) == 728689
            expect(imageRegion.asset!.xxhdpi!.imageType) == "image/jpeg"

            expect(imageRegion.asset!.hdpi).notTo(beNil())
            expect(imageRegion.asset!.hdpi!.width) == 750
            expect(imageRegion.asset!.hdpi!.height) == 321
            expect(imageRegion.asset!.hdpi!.size) == 77464
            expect(imageRegion.asset!.hdpi!.imageType) == "image/jpeg"

        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("ActivitySpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let post: Post = stub(["postId" : "768"])
                    let activity: Activity = stub(["subject" : post, "activityId" : "456"])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(activity, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let post: Post = stub(["postId" : "768"])
                    let activity: Activity = stub([
                        "subject" : post,
                        "activityId" : "456",
                        "kind" : "noise_post",
                        "subjectType" : "Post",
                        "createdAt" : expectedCreatedAt
                    ])

                    NSKeyedArchiver.archiveRootObject(activity, toFile: filePath)
                    let unArchivedActivity = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Activity

                    expect(unArchivedActivity).toNot(beNil())
                    expect(unArchivedActivity.version) == 1

                    expect(unArchivedActivity.activityId) == "456"
                    expect(unArchivedActivity.kind.rawValue) == Activity.Kind.NoisePost.rawValue
                    expect(unArchivedActivity.subjectType.rawValue) == Activity.SubjectType.Post.rawValue
                    expect(unArchivedActivity.createdAt) == expectedCreatedAt

                    let unArchivedPost = unArchivedActivity.subject as! Post
                    expect(unArchivedPost).to(beAKindOf(Post.self))
                    expect(unArchivedPost.postId) == "768"
                }
            }
        }
    }
}