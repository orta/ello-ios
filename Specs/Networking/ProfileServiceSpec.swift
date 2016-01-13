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

            let profileService = ProfileService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                }

                it("Calls success with a User") {
                    var loadedUser: User?

                    profileService.loadCurrentUser(ElloAPI.Profile(perPage: 10), success: { user in
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

        describe("updateUserProfile") {
            let profileService = ProfileService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                }

                it("Calls success with a User") {
                    var returnedUser: User?

                    profileService.updateUserProfile([:], success: { user in
                        returnedUser = user
                    }, failure: nil)

                    expect(returnedUser).toNot(beNil())

                    //smoke test the user
                    expect(returnedUser?.id) == "42"
                    expect(returnedUser?.username) == "odinarcher"
                    expect(returnedUser?.formattedShortBio) == "<p>I work for <strong>Odin</strong> now! MOTHER!</p>"
                }
            }
        }

        describe("deleteAccount") {
            let profileService = ProfileService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                }

                it("Calls success function") {
                    var called = false

                    profileService.deleteAccount(success: {
                        called = true
                    }, failure: nil)

                    expect(called) == true
                }
            }
        }
    }
}
