//
//  User.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

class User: JSONAble {
    dynamic let name: String
    dynamic let userId: Int
    dynamic let username: String
    dynamic let avatarURL: NSURL?

    init(name: String, userId: Int, username: String, avatarURL: NSURL?) {
        self.name = name
        self.userId = userId
        self.username = username
        self.avatarURL = avatarURL
    }

    override class func fromJSON(data:[String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
        let json = JSON(data)
        let name = json["name"].stringValue
        let userId = json["id"].intValue
        let username = json["username"].stringValue
        let avatarPath = json["avatar_url"].stringValue
        let avatarURL = NSURL(string: avatarPath)
        return User(name: name, userId: userId, username: username, avatarURL:avatarURL)
    }
}