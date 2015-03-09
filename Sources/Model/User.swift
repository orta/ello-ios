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


final class User: JSONAble {
    var atName : String { return "@\(username)"}
    let avatarURL: NSURL?
    let coverImageURL: NSURL?
    let experimentalFeatures: Bool
    let followersCount: Int?
    let followingCount: Int?
    let href: String
    let name: String
    let formattedShortBio: String
    var posts: [Post]
    let postsCount: Int?
    let relationshipPriority: String
    let userId: String
    let username: String

    // only set from
    var isCurrentUser : Bool

    init(avatarURL: NSURL?,
        coverImageURL: NSURL?,
        experimentalFeatures: Bool,
        followersCount: Int?,
        followingCount: Int?,
        href: String,
        name: String,
        posts: [Post],
        postsCount: Int?,
        relationshipPriority: String,
        userId: String,
        username: String,
        formattedShortBio: String,
        isCurrentUser: Bool = false)
    {
        self.avatarURL = avatarURL
        self.coverImageURL = coverImageURL
        self.experimentalFeatures = experimentalFeatures
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.href = href
        self.name = name
        self.posts = posts
        self.isCurrentUser = isCurrentUser
        self.postsCount = postsCount
        self.relationshipPriority = relationshipPriority
        self.userId = userId
        self.username = username
        self.formattedShortBio = formattedShortBio
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let name = json["name"].stringValue
        let userId = json["id"].stringValue
        let username = json["username"].stringValue
        let formattedShortBio = json["formatted_short_bio"].stringValue


        let experimentalFeatures = json["experimental_features"].boolValue
        let href = json["href"].stringValue
        let relationshipPriority = json["relationship_priority"].stringValue

        var avatarURL:NSURL?
        var coverImageURL:NSURL?

        if var avatar = json["avatar"].object as? [String:[String:AnyObject]] {
            if let avatarPath = avatar["large"]?["url"] as? String {
                avatarURL = NSURL(string: avatarPath, relativeToURL: NSURL(string: ElloURI.baseURL))
            }
        }

        if var coverImage = json["cover_image"].object as? [String:[String:AnyObject]] {
            if let coverPath = coverImage["hdpi"]?["url"] as? String {
                coverImageURL = NSURL(string: coverPath, relativeToURL: NSURL(string: ElloURI.baseURL))
            }
        }


        let postsCount = json["posts_count"].int
        let followersCount = json["followers_count"].int
        let followingCount = json["following_count"].int

        var links: [String: AnyObject]
        var userPosts = [Post]()
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            if let posts = links["posts"] as? [Post] {
                userPosts = posts
            }
        }

        let user = User(
            avatarURL: avatarURL,
            coverImageURL: coverImageURL,
            experimentalFeatures: experimentalFeatures,
            followersCount: followersCount,
            followingCount: followingCount,
            href: href,
            name: name,
            posts: userPosts,
            postsCount: postsCount,
            relationshipPriority: relationshipPriority,
            userId: userId,
            username: username,
            formattedShortBio: formattedShortBio
        )

        // hack back in author
        for post in user.posts {
            post.author = user
        }

        return user
    }

    class func fakeCurrentUser(username: String, avatarURL optlUrl : NSURL? = nil) -> User {
        let url = optlUrl ?? NSURL(string: "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/avatar/27/large_ello-09fd7088-2e4f-4781-87db-433d5dbc88a5.png")
        return User(
            avatarURL: url,
            coverImageURL: nil,
            experimentalFeatures: false,
            followersCount: 1,
            followingCount: 3,
            href: "/api/edge/users/42",
            name: "Unknown",
            posts: [],
            postsCount: 2,
            relationshipPriority: "self",
            userId: "42",
            username: username,
            formattedShortBio: "bio"
        )

    }
}
