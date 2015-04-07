//
//  ProfileServiceSpec.swift
//  Ello
//
//  Created by Sean on 2/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import Ello
import Quick
import Moya
import Nimble

class ProfileServiceSpec: QuickSpec {
    override func spec() {
        describe("-loadCurrentUser") {

            var profileService = ProfileService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                it("Calls success with a User") {
                    var loadedUser: User?

                    profileService.loadCurrentUser({ (user, responseConfig) in
                        loadedUser = user
                    }, failure: nil)

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.id) == "42"
                    expect(loadedUser!.username) == "archer"
                    expect(loadedUser!.formattedShortBio) == "<p>Have been <strong>spying</strong> for a while now.</p>"
                    expect(loadedUser!.coverImageURL?.absoluteString) == "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/cover_image/565/ello-hdpi-768defd5.jpg"
                }
            }

        }

        describe("loadCurrentUserFollowing") {
            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                it("calls success with a list of Users") {
                    let profileService = ProfileService()
                    var loadedUsers: [User]?

                    profileService.loadCurrentUserFollowing(forRelationship: Relationship.Friend, success: { users, _ in
                        loadedUsers = users
                    }, failure: .None)

                    expect(loadedUsers!.count).to(equal(2))

                    //smoke test the user
                    expect(loadedUsers!.first!.id) == "666"
                    expect(loadedUsers!.first!.username) == "cfiggis"
                }
            }
        }

        describe("updateUserProfile") {
            var profileService = ProfileService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                it("Calls success with a User") {
                    var returnedUser: User?

                    profileService.updateUserProfile([:], success: { user, responseConfig in
                        returnedUser = user
                    }, failure: nil)

                    expect(returnedUser).toNot(beNil())

                    //smoke test the user
                    expect(returnedUser?.userId) == "42"
                    expect(returnedUser?.username) == "odinarcher"
                    expect(returnedUser?.formattedShortBio) == "<p>I work for <strong>Odin</strong> now! MOTHER!</p>"
                }
            }
        }
    }
}
