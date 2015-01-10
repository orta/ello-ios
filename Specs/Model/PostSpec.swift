//
//  PostSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class PostSpec: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let body = [["data" : "@figgis ISIS agents use **Krav Maga.**", "kind" : "text"]]
            let createdAtString = "2013-11-30T05:57:53.936Z"
            let content = [ "<p><a href=\"/archer\" class=\"user-mention\" rel=\"nofollow\">@archer</a>, Will I get to learn karate?</p>"]
            let summary = [ "<p><a href='/archer' class='user-mention' rel='nofollow'>@archer</a>, Will I get to learn karate?</p>"]
            let token = "iQ7twNQtWwAQjBw4kEL1rg"
            let postId = 17

            let authorName = "Secret Spy"
            let authorId = 42
            let authorUsername = "archer"
            let authorAvatar = "http://ello.dev/uploads/user/avatar/42/avatar.png"
            let authorAvatarURL = NSURL(string: authorAvatar)
            let authorDict = ["avatar_url" : authorAvatar, "id" : authorId, "name" : authorName, "username" : authorUsername]

            let data:[String: AnyObject] = ["body" : body , "author" : authorDict, "created_at" : createdAtString, "content" : content, "summary" : summary, "token" : token, "id" : postId]

            let post = Post.fromJSON(data, linked: nil) as Post
            var createdAt:NSDate = createdAtString.toNSDate()!

            expect(post.createdAt) == createdAt
            expect(post.content) == content
            expect(post.summary) == summary
            expect(post.token) == token
            expect(post.postId) == postId

            expect(post.author).to(beAnInstanceOf(User.self))
            expect(post.author!.name) == authorName
            expect(post.author!.userId) == authorId
            expect(post.author!.username) == authorUsername
            expect(post.author!.avatarURL) == authorAvatarURL
        }
        
    }
}