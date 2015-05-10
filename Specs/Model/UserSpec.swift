//
//  UserSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class UserSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("users_user_details", "users")
                let user = User.fromJSON(data) as! User
                // active record
                expect(user.id) == "420"
                // required
                expect(user.href) == "/api/edge/users/420"
                expect(user.username) == "pam"
                expect(user.name) == "Pamilanderson"
                expect(user.experimentalFeatures) == true
                expect(user.relationshipPriority) == RelationshipPriority.None
                // optional
                expect(user.avatar).to(beAKindOf(Asset.self))
                expect(user.identifiableBy) == ""
                expect(user.postsCount!) == 3
                expect(user.followersCount!) == "0"
                expect(user.followingCount!) == 0
                expect(user.formattedShortBio) == "<p>Have been spying for a while now.</p>"
                expect(user.externalLinks) == "http://isis.com http://ello.co"
                expect(user.coverImage).to(beAKindOf(Asset.self))
                expect(user.backgroundPosition) == ""
                expect(user.isCurrentUser) == false

//                expect(user.mostRecentPost).toNot(beNil())
//                expect(user.mostRecentPost?.id) == "4721"
//                expect(user.mostRecentPost?.author) == user
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

                    let post: Post = stub(["id" : "sample-post-id"])
                    let stubbedMostRecentPost: Post = stub(["id" : "another-sample-post-id", "authorId" : "sample-userId"])
                    let attachment: Attachment = stub(["url": NSURL(string: "http://www.example.com")!, "height": 0, "width": 0, "type": "png", "size": 0 ])
                    let asset: Asset = stub(["regular" : attachment])
                    let coverAttachment: Attachment = stub(["url": NSURL(string: "http://www.example2.com")!, "height": 0, "width": 0, "type": "png", "size": 0 ])
                    let coverAsset: Asset = stub(["hdpi" : coverAttachment])

                    let user: User = stub([
                        "avatar" : asset,
                        "coverImage" : coverAsset,
                        "experimentalFeatures" : true,
                        "followersCount" : "6",
                        "followingCount" : 8,
                        "href" : "sample-href",
                        "name" : "sample-name",
                        "posts" : [post],
                        "postsCount" : 9,
                        "mostRecentPost" : stubbedMostRecentPost,
                        "relationshipPriority" : "self",
                        "id" : "sample-userId",
                        "username" : "sample-username",
                        "profile": Profile.stub(["email": "sample@email.com"]) ,
                        "formattedShortBio" : "sample-short-bio",
                        "externalLinks": "sample-external-links"
                    ])

                    NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
                    let unArchivedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! User

                    expect(unArchivedUser).toNot(beNil())
                    expect(unArchivedUser.version) == 1

                    expect(unArchivedUser.avatarURL?.absoluteString) == "http://www.example.com"
                    expect(unArchivedUser.coverImageURL?.absoluteString) == "http://www.example2.com"
                    expect(unArchivedUser.experimentalFeatures).to(beTrue())
                    expect(unArchivedUser.followersCount) == "6"
                    expect(unArchivedUser.followingCount) == 8
                    expect(unArchivedUser.href) == "sample-href"
                    expect(unArchivedUser.name) == "sample-name"

                    let firstPost = unArchivedUser.posts!.first!
                    expect(firstPost.id) == "sample-post-id"

                    expect(unArchivedUser.relationshipPriority.rawValue) == "self"
                    expect(unArchivedUser.id) == "sample-userId"
                    expect(unArchivedUser.username) == "sample-username"
                    expect(unArchivedUser.formattedShortBio) == "sample-short-bio"
                    expect(unArchivedUser.externalLinks) == "sample-external-links"
                    expect(unArchivedUser.isCurrentUser).to(beTrue())

                    expect(unArchivedUser.mostRecentPost).toNot(beNil())
                    expect(unArchivedUser.mostRecentPost?.id) == "another-sample-post-id"
                    expect(unArchivedUser.mostRecentPost?.author!.id) == unArchivedUser.id
                }
            }
        }
    }
}

