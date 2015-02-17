//
//  ProfileServiceSpec.swift
//  Ello
//
//  Created by Sean on 2/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

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

                    profileService.loadCurrentUser({ (user) -> () in
                        loadedUser = user
                    }, failure: nil)

                    expect(loadedUser).toNot(beNil())

                    //smoke test the user
                    expect(loadedUser!.userId) == "42"
                    expect(loadedUser!.username) == "archer"
                    expect(loadedUser!.formattedShortBio) == "<p>Have been <strong>spying</strong> for a while now.</p>"
                    expect(loadedUser!.coverImageURL?.absoluteString) == "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/cover_image/565/ello-hdpi-768defd5.jpg"
                }
            }

        }
    }
}

