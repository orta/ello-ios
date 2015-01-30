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

        it("converts from JSON") {
            let data = stubbedJSONData("user", "users")

            let user = User.fromJSON(data) as User
            
//            expect(user.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/42/avatar.png"
            expect(user.userId) == "42"
            expect(user.name) == "Sterling"
            expect(user.username) == "archer"
            expect(user.href) == "/api/edge/users/42"
            expect(user.experimentalFeatures) == false
            expect(user.relationshipPriority) == "self"
            expect(user.postsCount!) == 1
            expect(user.followersCount!) == 0
            expect(user.followingCount!) == 1
        }
    }
}

