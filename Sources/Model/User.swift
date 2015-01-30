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
    let name: String
    let userId: String
    let username: String
    let href: String
    let experimentalFeatures: Bool
    let relationshipPriority: String
    let avatarURL: NSURL?
    let pixellatedAvatarURL: NSURL?
    let followersCount: Int?
    let postsCount: Int?
    let followingCount: Int?

    init(name: String, userId: String, username: String, avatarURL: NSURL?, pixellatedAvatarURL: NSURL?, experimentalFeatures: Bool, href:String, relationshipPriority:String, followersCount:Int?, postsCount:Int?, followingCount:Int?) {
        self.name = name
        self.userId = userId
        self.username = username
        self.avatarURL = avatarURL
        self.experimentalFeatures = experimentalFeatures
        self.href = href
        self.relationshipPriority = relationshipPriority
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postsCount = postsCount
        self.pixellatedAvatarURL = pixellatedAvatarURL
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let linkedData = JSONAble.linkItems(data)
        let json = JSON(linkedData)
        let name = json["name"].stringValue
        let userId = json["id"].stringValue
        let username = json["username"].stringValue
//        var avatar = json["avatar"].object as [String:[String:String]]

        let experimentalFeatures = json["experimental_features"].boolValue
        let href = json["href"].stringValue
        let relationshipPriority = json["relationship_priority"].stringValue

//        var avatarPath = avatar["large"]?["url"]
        var avatarURL:NSURL?
//        if let avatarPath = avatarPath {
//            avatarURL = NSURL(string: avatarPath, relativeToURL: NSURL(string: "https://ello.co"))
//        }

//        var pixellatedAvatarPath = avatar["pixellated_large"]?["url"]
        var pixellatedAvatarURL:NSURL?
//        if let pixellatedAvatarPath = pixellatedAvatarPath {
//            pixellatedAvatarURL = NSURL(string: pixellatedAvatarPath, relativeToURL: NSURL(string: "https://ello.co"))
//        }

        let postsCount = json["posts_count"].int
        let followersCount = json["followers_count"].int
        let followingCount = json["following_count"].int
        
        return User(name: name, userId: userId, username: username, avatarURL:avatarURL, pixellatedAvatarURL:pixellatedAvatarURL, experimentalFeatures: experimentalFeatures, href:href, relationshipPriority:relationshipPriority, followersCount: followersCount, postsCount: postsCount, followingCount:followingCount)
    }
}