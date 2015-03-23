//
//  UserSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble

class UserSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("user", "users")
                let user = User.fromJSON(data) as User
                
    //            expect(user.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/42/avatar.png"
                expect(user.userId) == "42"
                expect(user.name) == "Sterling"
                expect(user.username) == "archer"
                expect(user.href) == "/api/edge/users/42"
                expect(user.experimentalFeatures) == false
                expect(user.relationshipPriority) == Relationship.Me
                expect(user.postsCount!) == 58
                expect(user.followersCount!) == 93
                expect(user.followingCount!) == 10

                // test "links"
                expect(user.posts.count) >= 1
                expect(user.posts[0]).to(beAKindOf(Post.self))

                expect(user.mostRecentPost).toNot(beNil())
                expect(user.mostRecentPost?.postId) == "4721"
                expect(user.mostRecentPost?.author) == user
            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("UserSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let user: User = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(user, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()

                    let post: Post = stub(["postId" : "sample-post-id"])
                    let stubbedMostRecentPost: Post = stub(["postId" : "another-sample-post-id"])

                    let user: User = stub([
                        "avatarURL" : NSURL(string: "http://www.example.com")!,
                        "coverImageURL" : NSURL(string: "http://www.example2.com")!,
                        "experimentalFeatures" : true,
                        "followersCount" : 6,
                        "followingCount" : 8,
                        "href" : "sample-href",
                        "name" : "sample-name",
                        "posts" : [post],
                        "postsCount" : 9,
                        "mostRecentPost" : stubbedMostRecentPost,
                        "relationshipPriority" : "self",
                        "userId" : "sample-userId",
                        "username" : "sample-username",
                        "formattedShortBio" : "sample-short-bio",
                        "externalLinks": "sample-external-links",
                        "isCurrentUser" : true
                    ])

                    user.mostRecentPost?.author = user

                    NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
                    let unArchivedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as User

                    expect(unArchivedUser).toNot(beNil())
                    expect(unArchivedUser.version) == 1

                    expect(unArchivedUser.avatarURL?.absoluteString) == "http://www.example.com"
                    expect(unArchivedUser.coverImageURL?.absoluteString) == "http://www.example2.com"
                    expect(unArchivedUser.experimentalFeatures).to(beTrue())
                    expect(unArchivedUser.followersCount) == 6
                    expect(unArchivedUser.followingCount) == 8
                    expect(unArchivedUser.href) == "sample-href"
                    expect(unArchivedUser.name) == "sample-name"

                    let firstPost = unArchivedUser.posts.first!
                    expect(firstPost.postId) == "sample-post-id"

                    expect(unArchivedUser.relationshipPriority.rawValue) == "self"
                    expect(unArchivedUser.userId) == "sample-userId"
                    expect(unArchivedUser.username) == "sample-username"
                    expect(unArchivedUser.formattedShortBio) == "sample-short-bio"
                    expect(unArchivedUser.externalLinks) == "sample-external-links"
                    expect(unArchivedUser.isCurrentUser).to(beTrue())

                    expect(unArchivedUser.mostRecentPost).toNot(beNil())
                    expect(unArchivedUser.mostRecentPost?.postId) == "another-sample-post-id"
                    expect(unArchivedUser.mostRecentPost?.author) == unArchivedUser
                }
            }
        }
    }
}

