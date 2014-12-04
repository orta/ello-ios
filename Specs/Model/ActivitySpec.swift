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

            let activityId = 123
            let subjectType = "User"
            let kind = "friend_post"
            let createdAtString = "2013-09-30T05:57:53.936Z"

            let avatar = "http://ello.dev/uploads/user/avatar/42/avatar.png"
            let avatarURL = NSURL(string: avatar)
            let userId = 42
            let name = "Secret Spy"
            let username = "archer"

            let subject:[String: AnyObject] = ["avatar_url" : avatar, "id" : userId, "name" : name, "username" : username]
            let data:[String: AnyObject] = ["kind" : kind, "subject" : subject, "created_at" : createdAtString, "subject_type" : subjectType, "id" : activityId]

            var createdAt:NSDate = dateFromServerString(createdAtString)!

            let activity = Activity.fromJSON(data) as Activity

            expect(activity.subjectType) == Activity.ActivitySubjectType.User
            expect(activity.activityId) == activityId
            expect(activity.kind) == Activity.ActivityKinds.FriendPost
            expect(activity.createdAt) == createdAt

            let user = activity.subject as User
            expect(user.avatarURL) == avatarURL
            expect(user.userId) == userId
            expect(user.name) == name
            expect(user.username) == username
        }


        it("converts Post activities from JSON") {
            let activityId = 666
            let subjectType = "Post"
            let kind = "welcome_post"
            let createdAtString = "2010-09-30T05:57:53.936Z"

            let body = [["data" : "@figgis ISIS agents use **Krav Maga.**", "kind" : "text"]]
            let postCreatedAtString = "2013-11-30T05:57:53.936Z"
            let content = [ "<p><a href=\"/archer\" class=\"user-mention\" rel=\"nofollow\">@archer</a>, Will I get to learn karate?</p>"]
            let summary = [ "<p><a href='/archer' class='user-mention' rel='nofollow'>@archer</a>, Will I get to learn karate?</p>"]
            let token = "iQ7twNQtWwAQjBw4kEL1rg"
            let postId = 17

            let subject:[String: AnyObject] = ["body" : body , "created_at" : postCreatedAtString, "content" : content, "summary" : summary, "token" : token, "id" : postId]

            let data:[String: AnyObject] = ["kind" : kind, "subject" : subject, "created_at" : createdAtString, "subject_type" : subjectType, "id" : activityId]

            var createdAt:NSDate = dateFromServerString(createdAtString)!

            var postCreatedAt:NSDate = dateFromServerString(postCreatedAtString)!

            let activity = Activity.fromJSON(data) as Activity

            expect(activity.subjectType) == Activity.ActivitySubjectType.Post
            expect(activity.activityId) == activityId
            expect(activity.kind) == Activity.ActivityKinds.WelcomPost
            expect(activity.createdAt) == createdAt

            let post = activity.subject as Post
//            expect(post.body) == body
            expect(post.createdAt) == postCreatedAt
            expect(post.content) == content
            expect(post.summary) == summary
            expect(post.token) == token
            expect(post.postId) == postId
        }
    }
}