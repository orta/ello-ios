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

struct User {
    var atName : String { return "@\(username)"}
    let avatarURL: NSURL?
    let experimentalFeatures: Bool
    let followersCount: Int?
    let followingCount: Int?
    let href: String
    let name: String
    var posts: [Post]
    let postsCount: Int?
    let relationshipPriority: String
    let userId: String
    let username: String
}
