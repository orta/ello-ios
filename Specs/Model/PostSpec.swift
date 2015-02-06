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
            let parsedPost = stubbedJSONDataWithLinked("posts", "posts")

            let createdAtString = "2014-12-23T22:27:47.325Z"
            let post = Post.fromJSON(parsedPost) as Post
            var createdAt:NSDate = createdAtString.toNSDate()!

            expect(post.createdAt) == createdAt

            let postContent0:ImageBlock = post.content[0] as ImageBlock
            expect(postContent0.kind) == Block.Kind.Image
            expect(postContent0.alt) == "ello-15c97681-b4a6-496f-8c5f-0096fd215703.jpeg"
            
            let postContent1:TextBlock = post.content[1] as TextBlock
            expect(postContent1.kind) == Block.Kind.Text
            expect(postContent1.content) == "test text content"
            
            
            expect(post.token) == "ibLWX5p5fPBfzE8GmfOG6w"
            expect(post.postId) == "526"

            expect(post.author).to(beAnInstanceOf(User.self))
            expect(post.author!.name) == "Cyril Figgis"
            expect(post.author!.userId) == "666"
            expect(post.author!.username) == "cfiggis"
            expect(post.author!.experimentalFeatures) == true
            expect(post.author!.relationshipPriority) == "friend"
            expect(post.author!.href) == "/api/edge/users/666"
            expect(post.author!.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/666/avatar.png"

            let imageBlock:ImageBlock = post.content[0] as ImageBlock

            expect(imageBlock.xxhdpi).notTo(beNil())
            expect(imageBlock.xxhdpi!.width) == 2560
            expect(imageBlock.xxhdpi!.height) == 1094
            expect(imageBlock.xxhdpi!.size) == 728689
            expect(imageBlock.xxhdpi!.imageType) == "image/jpeg"

            expect(imageBlock.hdpi).notTo(beNil())
            expect(imageBlock.hdpi!.width) == 750
            expect(imageBlock.hdpi!.height) == 321
            expect(imageBlock.hdpi!.size) == 77464
            expect(imageBlock.hdpi!.imageType) == "image/jpeg"        }
        
    }
}