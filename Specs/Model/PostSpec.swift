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
                let post = Post.fromJSON(parsedPost) as! Post
                var createdAt:NSDate = createdAtString.toNSDate()!

                expect(post.createdAt) == createdAt

                let postContent0:ImageRegion = post.content![0] as! ImageRegion
                expect(postContent0.kind) == RegionKind.Image.rawValue
                expect(postContent0.alt) == "ello-15c97681-b4a6-496f-8c5f-0096fd215703.jpeg"

                let postContent1:TextRegion = post.content![1] as! TextRegion
                expect(postContent1.kind) == RegionKind.Text.rawValue
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

                let imageRegion:ImageRegion = post.content![0] as! ImageRegion

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

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("PostSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let author: User = stub(["userId" : "555"])
                    let post: Post = stub([
                        "postId" : "768",
                        "author" : author
                    ])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(post, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let author: User = stub([
                        "userId" : "555"
                    ])

                    let hdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 35,
                        "width" : 45,
                        "imageType" : "jpeg",
                        "size" : 445566
                    ])

                    let xxhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 99,
                        "width" : 10,
                        "imageType" : "png",
                        "size" : 986896
                    ])

                    let asset: Asset = stub([
                        "assetId" : "qwerty",
                        "hdpi" : hdpi,
                        "xxhdpi" : xxhdpi
                    ])

                    let textRegion: TextRegion = stub([
                        "content" : "I am your content for sure"
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset" : asset,
                        "alt" : "some-altness",
                        "url" : NSURL(string: "http://www.example5.com")!
                    ])

                    let comment: Comment = stub([
                        "author": author
                    ])

                    let summary = [textRegion, imageRegion]
                    let content = [textRegion, imageRegion]

                    let post: Post = stub([
                        "assets" : ["assetUno" : asset],
                        "author" : author,
                        "collapsed" : true,
                        "postId" : "768",
                        "commentsCount" : 6,
                        "createdAt" : expectedCreatedAt,
                        "href" : "0987",
                        "repostsCount" : 99,
                        "token" : "toke-en",
                        "viewsCount" : 78,
                        "summary" : summary,
                        "content" : content,
                        "comments" : [comment]
                    ])

                    NSKeyedArchiver.archiveRootObject(post, toFile: filePath)
                    let unArchivedPost = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Post

                    expect(unArchivedPost).toNot(beNil())
                    expect(unArchivedPost.version) == 1
                    expect(unArchivedPost.createdAt) == expectedCreatedAt

                    expect(unArchivedPost.collapsed).to(beTrue())
                    expect(unArchivedPost.postId) == "768"
                    expect(unArchivedPost.commentsCount) == 6
                    expect(unArchivedPost.href) == "0987"
                    expect(unArchivedPost.repostsCount) == 99
                    expect(unArchivedPost.token) == "toke-en"
                    expect(unArchivedPost.viewsCount) == 78
                    expect(unArchivedPost.comments[0]).to(beAKindOf(Comment.self)) 

                    let postAuthor = unArchivedPost.author!

                    expect(postAuthor.userId) == "555"

                    expect(count(unArchivedPost.content!)) == 2

                    let region1 = unArchivedPost.content?[0] as! TextRegion

                    expect(region1.content) == "I am your content for sure"

                    let region2 = unArchivedPost.content?[1] as! ImageRegion

                    expect(region2.alt) == "some-altness"
                    expect(region2.url?.absoluteString) == "http://www.example5.com"

                    let region2Asset = region2.asset!

                    expect(region2Asset.assetId) == "qwerty"

                    let region2AssetXXHDPI = region2Asset.xxhdpi!

                    expect(region2AssetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(region2AssetXXHDPI.width) == 10
                    expect(region2AssetXXHDPI.height) == 99
                    expect(region2AssetXXHDPI.size) == 986896
                    expect(region2AssetXXHDPI.imageType) == "png"

                    let region2AssetHDPI = region2Asset.hdpi!

                    expect(region2AssetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(region2AssetHDPI.width) == 45
                    expect(region2AssetHDPI.height) == 35
                    expect(region2AssetHDPI.size) == 445566
                    expect(region2AssetHDPI.imageType) == "jpeg"

                    expect(count(unArchivedPost.summary!)) == 2

                    let region3 = unArchivedPost.summary?[0] as! TextRegion

                    expect(region3.content) == "I am your content for sure"

                    let region4 = unArchivedPost.summary?[1] as! ImageRegion

                    expect(region4.alt) == "some-altness"
                    expect(region4.url?.absoluteString) == "http://www.example5.com"

                    let region4Asset = region4.asset!

                    expect(region2Asset.assetId) == "qwerty"

                    let region4AssetXXHDPI = region4Asset.xxhdpi!

                    expect(region4AssetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(region4AssetXXHDPI.width) == 10
                    expect(region4AssetXXHDPI.height) == 99
                    expect(region4AssetXXHDPI.size) == 986896
                    expect(region4AssetXXHDPI.imageType) == "png"

                    let region4AssetHDPI = region4Asset.hdpi!

                    expect(region4AssetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(region4AssetHDPI.width) == 45
                    expect(region4AssetHDPI.height) == 35
                    expect(region4AssetHDPI.size) == 445566
                    expect(region4AssetHDPI.imageType) == "jpeg"
                }
            }
        }
    }
}