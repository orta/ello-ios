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

        it("converts User activities from JSON") {

            let parsedActivity = stubbedJSONData("activity-welcome-post", "activity")

            var createdAtString = "2014-06-01T00:00:00.000Z"
            var createdAt:NSDate = createdAtString.toNSDate()!

            let activity = Activity.fromJSON(parsedActivity, linked: nil) as Activity

            expect(activity.subjectType) == Activity.SubjectType.User
            expect(activity.activityId) == createdAtString
            expect(activity.kind) == Activity.Kind.WelcomPost
            expect(activity.createdAt) == createdAt

            let user = activity.subject as User
            expect(user.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/42/avatar.png"
            expect(user.userId) == "55"
            expect(user.name) == "Sterling"
            expect(user.username) == "archer"
            expect(user.href) == "/api/edge/users/42"
            expect(user.experimentalFeatures) == true
            expect(user.relationshipPriority) == "self"
            expect(user.postsCount!) == 456
            expect(user.followingCount!) == 111
            expect(user.followersCount!) == 10
        }

        it("converts Post activities from JSON") {
            let (parsedActivity, parsedLinked) = stubbedJSONDataWithLinked("activity-own-post", "activity")
            
            let activity = Activity.fromJSON(parsedActivity, linked: parsedLinked) as Activity

            var createdAtString = "2014-06-03T00:00:00.000Z"
            var createdAt:NSDate = createdAtString.toNSDate()!
            
            expect(activity.subjectType) == Activity.SubjectType.Post
            expect(activity.activityId) == createdAtString
            expect(activity.kind) == Activity.Kind.OwnPost
            expect(activity.createdAt) == createdAt

            let post = activity.subject as Post
            var postCreatedAt:NSDate = "2014-12-23T22:27:47.341Z".toNSDate()!
            expect(post.createdAt) == postCreatedAt

            let postContent0:TextBlock = post.content[0] as TextBlock
            expect(postContent0.kind) == Block.Kind.Text
            expect(postContent0.content) == "yo mang"
            
            expect(post.token) == "KVNldSWCvfPkjsbWcvB4mA"
            expect(post.postId) == "598"
            
            let postAuthor = post.author!
            expect(postAuthor.userId) == "42"
            expect(postAuthor.username) == "archer"
            expect(postAuthor.name) == "Sterling"
            expect(postAuthor.experimentalFeatures) == false
            expect(postAuthor.relationshipPriority) == "self"
            expect(postAuthor.href) == "/api/edge/users/42"
        }
    }
}