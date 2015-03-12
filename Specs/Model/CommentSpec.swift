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
            expect(commentContent0.kind) == RegionKind.Text.rawValue
            expect(commentContent0.content) == "Hello, I am a comment with awesome content!"

            expect(comment.commentId) == "30"
            
            let commentAuthor:User = comment.author!
            
            expect(commentAuthor).to(beAnInstanceOf(User.self))
            expect(commentAuthor.name) == "Smalls"
            expect(commentAuthor.userId) == "420"
            expect(commentAuthor.username) == "bigE"
            expect(commentAuthor.href) == "/api/edge/users/420"
            expect(commentAuthor.relationshipPriority) == Relationship.Friend
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
            expect(postAuthor.relationshipPriority) == Relationship.Friend
            expect(postAuthor.experimentalFeatures) == true
            expect(postAuthor.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/666/avatar.png"

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

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()

                    let parentPost: Post = stub([
                        "postId" : "sample-parent-post-id"
                    ])

                    let author: User = stub([
                        "userId" : "sample-author-id"
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

                    let summary = [textRegion, imageRegion]
                    let content = [textRegion, imageRegion]


                    let comment: Comment = stub([
                        "author" : author,
                        "commentId" : "362",
                        "createdAt" : expectedCreatedAt,
                        "parentPost" : parentPost,
                        "summary" : summary,
                        "content" : content
                    ])

                    NSKeyedArchiver.archiveRootObject(comment, toFile: filePath)
                    let unArchivedComment = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as Comment

                    expect(unArchivedComment).toNot(beNil())
                    expect(unArchivedComment.version) == 1
                    expect(unArchivedComment.createdAt) == expectedCreatedAt

                    expect(unArchivedComment.commentId) == "362"

                    let commentAuthor = unArchivedComment.author!

                    expect(commentAuthor.userId) == "sample-author-id"

                    let commentParentPost = unArchivedComment.parentPost!

                    expect(commentParentPost.postId) == "sample-parent-post-id"

                    expect(countElements(unArchivedComment.content!)) == 2

                    let region1 = unArchivedComment.content?[0] as TextRegion

                    expect(region1.content) == "I am your comment's content"

                    let region2 = unArchivedComment.content?[1] as ImageRegion

                    expect(region2.alt) == "sample-alt"
                    expect(region2.url?.absoluteString) == "http://www.example5.com"

                    let region2Asset = region2.asset!

                    expect(region2Asset.assetId) == "qwerty"

                    let region2AssetXXHDPI = region2Asset.xxhdpi!

                    expect(region2AssetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(region2AssetXXHDPI.width) == 112
                    expect(region2AssetXXHDPI.height) == 98
                    expect(region2AssetXXHDPI.size) == 5673
                    expect(region2AssetXXHDPI.imageType) == "png"

                    let region2AssetHDPI = region2Asset.hdpi!

                    expect(region2AssetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(region2AssetHDPI.width) == 887
                    expect(region2AssetHDPI.height) == 122
                    expect(region2AssetHDPI.size) == 666987
                    expect(region2AssetHDPI.imageType) == "jpeg"

                    expect(countElements(unArchivedComment.summary!)) == 2

                    let region3 = unArchivedComment.summary?[0] as TextRegion

                    expect(region3.content) == "I am your comment's content"

                    let region4 = unArchivedComment.summary?[1] as ImageRegion

                    expect(region4.alt) == "sample-alt"
                    expect(region4.url?.absoluteString) == "http://www.example5.com"

                    let region4Asset = region4.asset!

                    expect(region2Asset.assetId) == "qwerty"

                    let region4AssetXXHDPI = region4Asset.xxhdpi!
                    
                    expect(region4AssetXXHDPI.url!.absoluteString) == "http://www.example2.com"
                    expect(region4AssetXXHDPI.width) == 112
                    expect(region4AssetXXHDPI.height) == 98
                    expect(region4AssetXXHDPI.size) == 5673
                    expect(region4AssetXXHDPI.imageType) == "png"
                    
                    let region4AssetHDPI = region4Asset.hdpi!
                    
                    expect(region4AssetHDPI.url!.absoluteString) == "http://www.example.com"
                    expect(region4AssetHDPI.width) == 887
                    expect(region4AssetHDPI.height) == 122
                    expect(region4AssetHDPI.size) == 666987
                    expect(region4AssetHDPI.imageType) == "jpeg"
                }
            }
        }
    }
}
