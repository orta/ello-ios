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

        describe("+fromJSON:") {

            it("parses correctly") {
                let parsedPost = stubbedJSONData("posts", "posts")

                let createdAtString = "2014-12-23T22:27:47.325Z"
                let post = Post.fromJSON(parsedPost) as Post
                var createdAt:NSDate = createdAtString.toNSDate()!

                expect(post.createdAt) == createdAt

                let postContent0:ImageRegion = post.content![0] as ImageRegion
                expect(postContent0.kind) == RegionKind.Image
                expect(postContent0.alt) == "ello-15c97681-b4a6-496f-8c5f-0096fd215703.jpeg"

                let postContent1:TextRegion = post.content![1] as TextRegion
                expect(postContent1.kind) == RegionKind.Text
                expect(postContent1.content) == "test text content"

                expect(post.token) == "ibLWX5p5fPBfzE8GmfOG6w"
                expect(post.postId) == "526"
                expect(post.shareLink) == "https://ello-staging.herokuapp.com/cfiggis/post/ibLWX5p5fPBfzE8GmfOG6w"
                expect(post.groupId) == "526"

                expect(post.author).to(beAnInstanceOf(User.self))
                expect(post.author!.name) == "Cyril Figgis"
                expect(post.author!.userId) == "666"
                expect(post.author!.username) == "cfiggis"
                expect(post.author!.experimentalFeatures) == true
                expect(post.author!.relationshipPriority) == Relationship.Friend
                expect(post.author!.href) == "/api/edge/users/666"
                expect(post.author!.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/666/avatar.png"

                let imageRegion:ImageRegion = post.content![0] as ImageRegion

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

                // test "links"
                expect(post.author).to(beAKindOf(User.self))
            }
        }
    }
}