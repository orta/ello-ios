//
//  PostSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class PostSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            beforeEach {
                ElloURI.domain = "ello.co"
            }

            it("parses correctly") {
                let parsedPost = stubbedJSONData("posts_post_details", "posts")

                let createdAtString = "2014-06-01T00:00:00.000Z"
                let post = Post.fromJSON(parsedPost) as! Post
                var createdAt: NSDate = createdAtString.toNSDate()!
                // active record
                expect(post.id) == "132"
                expect(post.createdAt) == createdAt
                // required
                expect(post.href) == "/api/edge/posts/132"
                expect(post.token) == "2rz4agLM4f1fyxykW3rc-Q"
                expect(post.contentWarning) == ""
                expect(post.allowComments) == true
                expect(count(post.summary)) == 2
                expect(post.summary[0].kind) == "text"
                expect(post.summary[1].kind) == "image"
                // optional
                expect(count(post.content!)) == 2
                expect(post.content![0].kind) == "text"
                expect(post.content![1].kind) == "image"
                expect(post.viewsCount) == 1
                expect(post.commentsCount) == 3
                expect(post.repostsCount) == 0
                // TODO: create a JSON that has all of these optionals in it
                // links
                expect(post.author).to(beAKindOf(User.self))
                expect(count(post.comments!)) == 2
                expect(post.comments![0]).to(beAKindOf(Comment.self))
                expect(post.comments![1]).to(beAKindOf(Comment.self))
                expect(count(post.assets!)) == 1
                expect(post.assets!["11"]).to(beAKindOf(Asset.self))
                // computed
                expect(post.groupId) == "132"
                expect(post.shareLink) == "https://ello.co/cfiggis/post/2rz4agLM4f1fyxykW3rc-Q"
                expect(post.collapsed).to(beFalse())
            }

        }

        describe("UpdatePostCommentCountNotification") {
            it("responds to notification") {
                let parsedPost = stubbedJSONData("posts", "posts")
                let post = Post.fromJSON(parsedPost) as! Post
                post.commentsCount = 1
                let user: User = stub(["username": "ello"])
                let comment = Comment.newCommentForPost(post, currentUser: user)
                postNotification(UpdatePostCommentCountNotification, comment)
                expect(post.commentsCount).to(equal(2))
            }

            it("ignores notifications from other posts") {
                var parsedPost1 = stubbedJSONData("posts", "posts")
                parsedPost1["id"] = "1"
                let post1 = Post.fromJSON(parsedPost1) as! Post
                post1.commentsCount = 1

                var parsedPost2 = stubbedJSONData("posts", "posts")
                parsedPost2["id"] = "2"
                let post2 = Post.fromJSON(parsedPost2) as! Post
                post2.commentsCount = 1

                let user: User = stub(["username": "ello"])
                let comment = Comment.newCommentForPost(post2, currentUser: user)
                postNotification(UpdatePostCommentCountNotification, comment)
                expect(post1.commentsCount).to(equal(1))
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
                    let post: Post = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(post, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                func testRegionContent(content: [Regionable]) {
                    expect(count(content)) == 2
                    let textRegion = content[0] as! TextRegion
                    let imageRegion = content[1] as! ImageRegion
                    let imageAsset = imageRegion.asset!
                    expect(textRegion.content) == "I am your content for sure"
                    expect(imageRegion.alt) == "some-altness"
                    expect(imageRegion.url?.absoluteString) == "http://www.example5.com"
                    expect(imageAsset.assetId) == "qwerty"

                    let assetXXHDPI = imageAsset.xxhdpi!
                    expect(assetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(assetXXHDPI.width) == 10
                    expect(assetXXHDPI.height) == 99
                    expect(assetXXHDPI.size) == 986896
                    expect(assetXXHDPI.imageType) == "png"

                    let assetHDPI = imageAsset.hdpi!
                    expect(assetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(assetHDPI.width) == 45
                    expect(assetHDPI.height) == 35
                    expect(assetHDPI.size) == 445566
                    expect(assetHDPI.imageType) == "jpeg"
                }

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let author: User = stub([
                        "id" : "555"
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
                    let repostContent = [textRegion, imageRegion]

                    let post: Post = stub([
                        // active record
                        "id" : "768",
                        "createdAt" : expectedCreatedAt,
                        // required
                        "href" : "0987",
                        "token" : "toke-en",
                        "contentWarning" : "null",
                        "allowComments" : true,
                        "summary" : summary,
                        // optional
                        "content" : content,
                        "repostContent" : repostContent,
                        "repostId" : "910",
                        "repostPath" : "http://ello.co/910",
                        "repostViaId" : "112",
                        "repostViaPath" : "http://ello.co/112",
                        "viewsCount" : 78,
                        "commentsCount" : 6,
                        "repostsCount" : 99,
                        // links
                        "assets" : ["assetUno" : asset],
                        "author" : author,
                        "comments" : [comment]
                    ])

                    NSKeyedArchiver.archiveRootObject(post, toFile: filePath)
                    let unArchivedPost = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Post

                    expect(unArchivedPost).toNot(beNil())
                    expect(unArchivedPost.version) == 1
                    // active record
                    expect(unArchivedPost.id) == "768"
                    expect(unArchivedPost.createdAt) == expectedCreatedAt
                    // required
                    expect(unArchivedPost.href) == "0987"
                    expect(unArchivedPost.token) == "toke-en"
                    expect(unArchivedPost.contentWarning) == "null"
                    expect(unArchivedPost.allowComments) == true
                    testRegionContent(unArchivedPost.summary)
                    // optional
                    testRegionContent(unArchivedPost.content!)
                    testRegionContent(unArchivedPost.repostContent!)
                    expect(unArchivedPost.repostId) == "910"
                    expect(unArchivedPost.repostPath!.absoluteString) == "http://ello.co/910"
                    expect(unArchivedPost.repostViaId) == "112"
                    expect(unArchivedPost.repostViaPath!.absoluteString) == "http://ello.co/112"
                    expect(unArchivedPost.viewsCount) == 78
                    expect(unArchivedPost.commentsCount) == 6
                    expect(unArchivedPost.repostsCount) == 99
                    // links
                    expect(unArchivedPost.author!.userId) == "555"
                    expect(count(unArchivedPost.assets!)) == 1
                    expect(count(unArchivedPost.comments!)) == 1
                    expect(unArchivedPost.comments![0]).to(beAKindOf(Comment.self))
                    // computed
                    expect(post.collapsed) == false
                    expect(post.shareLink) == "https://ello-staging.herokuapp.com/thenim/post/toke-en"
                }
            }
        }
    }
}

