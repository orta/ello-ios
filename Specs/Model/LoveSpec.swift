//
//  LoveSpec.swift
//  Ello
//
//  Created by Sean on 5/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class LoveSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("love", "loves")
                let love = Love.fromJSON(data) as! Love

                let createdAtString = "2014-06-01T00:00:00.000Z"
                var createdAt: NSDate = createdAtString.toNSDate()!

                let updatedAtString = "2014-06-01T00:00:00.000Z"
                var updatedAt: NSDate = updatedAtString.toNSDate()!

                // active record
                expect(love.id) == "5381"
                expect(love.createdAt) == createdAt
                expect(love.updatedAt) == updatedAt
                // required
                expect(love.deleted) == true
                expect(love.postId) == "1234"
                expect(love.userId) == "666"
                expect(love.post).to(beAKindOf(Post.self))
                expect(love.user).to(beAKindOf(User.self))
            }
        }

        context("NSCoding") {

            var filePath = ""

            beforeEach {
                filePath = NSFileManager.ElloDocumentsDir().stringByAppendingPathComponent("LoveSpec")
            }

            afterEach {
                var error:NSError?
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
            }

            context("encoding") {

                it("encodes successfully") {
                    let love: Love = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(love, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let expectedCreatedAt = NSDate()
                    let expectedUpdatedAt = NSDate()

                    let user: User = stub([
                        "id" : "444"
                    ])

                    let post: Post = stub([
                        "id" : "888"
                    ])

                    let love: Love = stub([
                        "user" : user,
                        "post" : post,
                        "id" : "999",
                        "deleted" : true,
                        "createdAt" : expectedCreatedAt,
                        "updatedAt" : expectedUpdatedAt,
                        "postId" : "888",
                        "userId" : "444"
                    ])

                    NSKeyedArchiver.archiveRootObject(love, toFile: filePath)
                    let unArchivedLove = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Love

                    expect(unArchivedLove).toNot(beNil())
                    expect(unArchivedLove.version) == 1

                    // active record
                    expect(unArchivedLove.id) == "999"
                    expect(unArchivedLove.createdAt) == expectedCreatedAt
                    expect(unArchivedLove.updatedAt) == expectedUpdatedAt
                    // required
                    expect(unArchivedLove.deleted) == true
                    expect(unArchivedLove.postId) == "888"
                    expect(unArchivedLove.userId) == "444"
                }
            }
        }
    }
}
