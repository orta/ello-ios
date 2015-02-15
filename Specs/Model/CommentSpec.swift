//
//  CommentSpec.swift
//  Ello
//
//  Created by Sean on 1/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class CommentSpec: QuickSpec {
    override func spec() {
        
        it("converts from JSON") {
            let parsedComment = stubbedJSONData("comments", "comments")

            let createdAtString = "2014-06-02T00:00:00.000Z"
            let comment = Comment.fromJSON(parsedComment) as Comment
            
            var createdAt:NSDate = createdAtString.toNSDate()!
            
            expect(comment.createdAt) == createdAt
            
            let commentContent0:TextRegion = comment.content![0] as TextRegion
            expect(commentContent0.kind) == RegionKind.Text
            expect(commentContent0.content) == "Hello, I am a comment with awesome content!"

            expect(comment.commentId) == "30"
            
            let commentAuthor:User = comment.author!
            
            expect(commentAuthor).to(beAnInstanceOf(User.self))
            expect(commentAuthor.name) == "Smalls"
            expect(commentAuthor.userId) == "420"
            expect(commentAuthor.username) == "bigE"
            expect(commentAuthor.href) == "/api/edge/users/420"
            expect(commentAuthor.relationshipPriority) == "friend"
            expect(commentAuthor.experimentalFeatures) == true
            expect(commentAuthor.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/420/avatar.png"

            var postCreatedAt:NSDate = "2014-12-23T22:27:47.325Z".toNSDate()!
            
            expect(comment.parentPost).to(beAnInstanceOf(Post.self))
            expect(comment.parentPost!.token) == "ibLWX5p5fPBfzE8GmfOG6w"
            expect(comment.parentPost!.postId) == "29"
            expect(comment.parentPost!.href) == "/api/edge/posts/29"
            expect(comment.parentPost!.createdAt) == postCreatedAt
            expect(comment.parentPost!.viewsCount) == 25
            expect(comment.parentPost!.commentsCount) == 10
            expect(comment.parentPost!.repostsCount) == 52
            expect(comment.parentPost!.collapsed) == false
            
            let postAuthor:User = comment.parentPost!.author!
            
            expect(postAuthor).to(beAnInstanceOf(User.self))
            expect(postAuthor.name) == "Cyril Figgis"
            expect(postAuthor.userId) == "666"
            expect(postAuthor.username) == "cfiggis"
            expect(postAuthor.href) == "/api/edge/users/666"
            expect(postAuthor.relationshipPriority) == "friend"
            expect(postAuthor.experimentalFeatures) == true
            expect(postAuthor.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/666/avatar.png"

        }
    }
}
