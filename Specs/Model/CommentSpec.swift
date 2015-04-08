//
//  CommentSpec.swift
//  Ello
//
//  Created by Sean on 1/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class CommentSpec: QuickSpec {
    override func spec() {
        describe("+fromJSON:") {

            it("parses correctly") {
                // add stubs for references in json
                ElloLinkedStore.store["posts"] = ["40": Post.stub(["id": "40"])]
                ElloLinkedStore.store["users"] = ["420": User.stub(["userId": "420"])]

                let parsedComment = stubbedJSONData("comments_comment_details", "comments")

                let createdAtString = "2014-06-02T00:00:00.000Z"
                let comment = Comment.fromJSON(parsedComment) as! Comment
                var createdAt: NSDate = createdAtString.toNSDate()!
                // active record
                expect(comment.id) == "41"
                expect(comment.createdAt) == createdAt
                // required
                expect(comment.postId) == "40"
                expect(count(comment.content)) == 2
                expect(comment.content[0].kind) == "text"
                expect(comment.content[1].kind) == "image"
                // links
                expect(comment.author).to(beAKindOf(User.self))
                expect(comment.parentPost).to(beAKindOf(Post.self))
                expect(count(comment.assets!)) == 1
                expect(comment.assets!["5"]).to(beAKindOf(Asset.self))
                // computed
                expect(comment.groupId) == "40"
            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("CommentSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let comment: Comment = stub([:])
                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(comment, toFile: filePath)
                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                func testRegionContent(content: [Regionable]) {
                    expect(count(content)) == 2
                    let textRegion = content[0] as! TextRegion
                    let imageRegion = content[1] as! ImageRegion
                    let imageAsset = imageRegion.asset!
                    expect(textRegion.content) == "I am your comment's content"
                    expect(imageRegion.alt) == "sample-alt"
                    expect(imageRegion.url?.absoluteString) == "http://www.example5.com"
                    expect(imageAsset.assetId) == "qwerty"

                    let assetXXHDPI = imageAsset.xxhdpi!
                    expect(assetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(assetXXHDPI.width) == 112
                    expect(assetXXHDPI.height) == 98
                    expect(assetXXHDPI.size) == 5673
                    expect(assetXXHDPI.imageType) == "png"

                    let assetHDPI = imageAsset.hdpi!
                    expect(assetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(assetHDPI.width) == 887
                    expect(assetHDPI.height) == 122
                    expect(assetHDPI.size) == 666987
                    expect(assetHDPI.imageType) == "jpeg"
                }

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()

                    let parentPost: Post = stub([
                        "id" : "sample-parent-post-id"
                    ])

                    let author: User = stub([
                        "id" : "sample-author-id"
                    ])

                    let hdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 122,
                        "width" : 887,
                        "imageType" : "jpeg",
                        "size" : 666987
                    ])

                    let xxhdpi: ImageAttachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 98,
                        "width" : 112,
                        "imageType" : "png",
                        "size" : 5673
                    ])

                    let asset: Asset = stub([
                        "assetId" : "qwerty",
                        "hdpi" : hdpi,
                        "xxhdpi" : xxhdpi
                    ])

                    let textRegion: TextRegion = stub([
                        "content" : "I am your comment's content"
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset" : asset,
                        "alt" : "sample-alt",
                        "url" : NSURL(string: "http://www.example5.com")!
                    ])

                    let content = [textRegion, imageRegion]

                    let comment: Comment = stub([
                        "author" : author,
                        "id" : "362",
                        "createdAt" : expectedCreatedAt,
                        "parentPost" : parentPost,
                        "content" : content,
                        "postId" : "42"
                    ])

                    NSKeyedArchiver.archiveRootObject(comment, toFile: filePath)
                    let unArchivedComment = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Comment

                    expect(unArchivedComment).toNot(beNil())
                    expect(unArchivedComment.version) == 1
                    // active record
                    expect(unArchivedComment.id) == "362"
                    expect(unArchivedComment.createdAt) == expectedCreatedAt
                    // required
                    expect(unArchivedComment.postId) == "42"
                    testRegionContent(unArchivedComment.content)
                }
            }
        }
    }
}
