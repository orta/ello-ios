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
            let parsedActivity = stubbedJSONDataWithLinked("activity-own-post", "activity")
            let activity = Activity.fromJSON(parsedActivity) as Activity

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
            expect(postAuthor.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/420/large_pam.png"

            let imageBlock:ImageBlock = post.content[1] as ImageBlock

            expect(imageBlock.xxhdpi).notTo(beNil())
            expect(imageBlock.xxhdpi!.width) == 2560
            expect(imageBlock.xxhdpi!.height) == 1094
            expect(imageBlock.xxhdpi!.size) == 728689
            expect(imageBlock.xxhdpi!.imageType) == "image/jpeg"

            expect(imageBlock.hdpi).notTo(beNil())
            expect(imageBlock.hdpi!.width) == 750
            expect(imageBlock.hdpi!.height) == 321
            expect(imageBlock.hdpi!.size) == 77464
            expect(imageBlock.hdpi!.imageType) == "image/jpeg"

        }
    }
}