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
            let avatar = "http://ello.dev/uploads/user/avatar/42/avatar.png"
            let avatarURL = NSURL(string: avatar)
            let userId = 42
            let name = "Secret Spy"
            let username = "archer"

            let data:[String: AnyObject] = ["avatar_url" : avatar, "id" : userId, "name" : name, "username" : username]

            let user = User.fromJSON(data, linked: nil) as User

            expect(user.avatarURL) == avatarURL
            expect(user.userId) == userId
            expect(user.name) == name
            expect(user.username) == username
        }
    }
}

