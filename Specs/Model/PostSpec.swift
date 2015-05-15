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

        beforeEach {
            ElloURI.domain = "ello.co"
        }
        
        describe("+fromJSON:") {

            it("parses correctly") {
                let parsedPost = stubbedJSONData("posts_post_details", "posts")

                let createdAtString = "2014-06-01T00:00:00.000Z"
                let post = Post.fromJSON(parsedPost) as! Post
                var createdAt: NSDate = createdAtString.toNSDate()!
                // active record
                expect(post.id) == "156"
                expect(post.createdAt) == createdAt
                // required
                expect(post.href) == "/api/edge/posts/156"
                expect(post.token) == "zBusVQHki_mBNJsNbBNg5w"
                expect(post.contentWarning) == ""
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
                expect(post.assets![0]).to(beAKindOf(Asset.self))
                // computed
                expect(post.groupId) == "156"
                expect(post.shareLink) == "https://ello.co/cfiggis/post/zBusVQHki_mBNJsNbBNg5w"
                expect(post.collapsed).to(beFalse())
            }

            it("parses created reposts correctly") {
                let parsedPost = stubbedJSONData("posts_creating_a_repost", "posts")

                let createdAtString = "2015-04-29T23:33:54.738Z"
                let post = Post.fromJSON(parsedPost) as! Post
                var createdAt: NSDate = createdAtString.toNSDate()!
                // active record
                expect(post.id) == "201"
                expect(post.createdAt) == createdAt
                // required
                expect(post.href) == "/api/edge/posts/201"
                expect(post.token) == "NAk0KZtpCB7xLGZtmUuhWA"
                expect(post.contentWarning) == ""
                expect(count(post.summary)) == 2
                expect(post.summary[0].kind) == "text"
                expect(post.summary[1].kind) == "image"
                // optional
                expect(count(post.content!)) == 1
                expect(post.repostContent![0].kind) == "text"
                expect(post.viewsCount) == 0
                expect(post.commentsCount) == 0
                expect(post.repostsCount) == 2
                expect(count(post.repostContent!)) == 2
                expect(post.repostContent![0].kind) == "text"
                expect(post.repostContent![1].kind) == "image"
                // TODO: create a JSON that has all of these optionals in it
                // links
                expect(post.repostAuthor!).to(beAKindOf(User.self))
                expect(count(post.comments!)) == 0
                expect(count(post.assets!)) == 1
                expect(post.assets![0]).to(beAKindOf(Asset.self))
                // computed
                expect(post.groupId) == "201"
                expect(post.shareLink) == "https://ello.co/archer/post/NAk0KZtpCB7xLGZtmUuhWA"
                expect(post.collapsed).to(beFalse())
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
                    expect(imageAsset.id) == "qwerty"

                    let assetXXHDPI = imageAsset.xxhdpi!
                    expect(assetXXHDPI.url.absoluteString) == "http://www.example2.com"
                    expect(assetXXHDPI.width) == 10
                    expect(assetXXHDPI.height) == 99
                    expect(assetXXHDPI.size) == 986896
                    expect(assetXXHDPI.type) == "png"

                    let assetHDPI = imageAsset.hdpi!
                    expect(assetHDPI.url.absoluteString) == "http://www.example.com"
                    expect(assetHDPI.width) == 45
                    expect(assetHDPI.height) == 35
                    expect(assetHDPI.size) == 445566
                    expect(assetHDPI.type) == "jpeg"
                }

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let author: User = stub([
                        "id" : "555",
                        "username": "thenim"
                    ])

                    let hdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 35,
                        "width" : 45,
                        "type" : "jpeg",
                        "size" : 445566
                    ])

                    let xxhdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 99,
                        "width" : 10,
                        "type" : "png",
                        "size" : 986896
                    ])

                    let asset: Asset = stub([
                        "id" : "qwerty",
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
                        "contentWarning" : "NSFW.",
                        "allowComments" : true,
                        "summary" : summary,
                        // optional
                        "content" : content,
                        "repostContent" : repostContent,
                        "repostId" : "910",
                        "collapsed" : true,
                        "repostPath" : "http://ello.co/910",
                        "repostViaId" : "112",
                        "repostViaPath" : "http://ello.co/112",
                        "viewsCount" : 78,
                        "commentsCount" : 6,
                        "repostsCount" : 99,
                        // links
                        "assets" : [asset],
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
                    expect(unArchivedPost.contentWarning) == "NSFW."
                    expect(unArchivedPost.collapsed) == true
                    expect(unArchivedPost.allowComments) == true
                    testRegionContent(unArchivedPost.summary)
                    // optional
                    testRegionContent(unArchivedPost.content!)
                    testRegionContent(unArchivedPost.repostContent!)
                    expect(unArchivedPost.repostId) == "910"
                    expect(unArchivedPost.repostPath) == "http://ello.co/910"
                    expect(unArchivedPost.repostViaId) == "112"
                    expect(unArchivedPost.repostViaPath) == "http://ello.co/112"
                    expect(unArchivedPost.viewsCount) == 78
                    expect(unArchivedPost.commentsCount) == 6
                    expect(unArchivedPost.repostsCount) == 99
                    // links
                    expect(unArchivedPost.author!.id) == "555"
                    expect(count(unArchivedPost.assets!)) == 1
                    expect(count(unArchivedPost.comments!)) == 1
                    expect(unArchivedPost.comments![0]).to(beAKindOf(Comment.self))
                    // computed
                    expect(post.collapsed) == true
                    expect(post.shareLink) == "https://ello.co/thenim/post/toke-en"
                }
            }
        }
    }
}

