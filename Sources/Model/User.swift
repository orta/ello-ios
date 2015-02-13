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

    init(avatarURL: NSURL?,
        experimentalFeatures: Bool,
        followersCount: Int?,
        followingCount: Int?,
        href: String,
        name: String,
        posts: [Post],
        postsCount: Int?,
        relationshipPriority: String,
        userId: String,
        username: String)
    {
        self.avatarURL = avatarURL
        self.experimentalFeatures = experimentalFeatures
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.href = href
        self.name = name
        self.posts = posts
        self.postsCount = postsCount
        self.relationshipPriority = relationshipPriority
        self.userId = userId
        self.username = username
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let name = json["name"].stringValue
        let userId = json["id"].stringValue
        let username = json["username"].stringValue


        let experimentalFeatures = json["experimental_features"].boolValue
        let href = json["href"].stringValue
        let relationshipPriority = json["relationship_priority"].stringValue

        var avatarURL:NSURL?

        if var avatar = json["avatar"].object as? [String:[String:AnyObject]] {
            if let avatarPath = avatar["large"]?["url"] as? String {
                avatarURL = NSURL(string: avatarPath, relativeToURL: NSURL(string: "https://ello.co"))
            }
        }

        let postsCount = json["posts_count"].int
        let followersCount = json["followers_count"].int
        let followingCount = json["following_count"].int

        var links = [String: AnyObject]()
        var posts = [Post]()
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            //            posts = links["posts"] as [Post]
        }

        return User(
            avatarURL: avatarURL,
            experimentalFeatures: experimentalFeatures,
            followersCount: followersCount,
            followingCount: followingCount,
            href: href,
            name: name,
            posts: posts,
            postsCount: postsCount,
            relationshipPriority: relationshipPriority,
            userId: userId,
            username: username
        )
    }
}
