//
//  UserExtensions.swift
//  Ello
//
//  Created by Sean on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension User: JSONAble {
    
    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
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

        var links = [String: Any]()
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
