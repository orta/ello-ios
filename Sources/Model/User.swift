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

let UserVersion = 1

final class User: JSONAble, NSCoding {

    let version: Int = UserVersion

    var atName : String { return "@\(username)"}
    let avatarURL: NSURL?
    let coverImageURL: NSURL?
    let experimentalFeatures: Bool
    let followersCount: Int?
    let followingCount: Int?
    let href: String
    let name: String
    let formattedShortBio: String
    let externalLinks: String
    var posts: [Post]
    let postsCount: Int?
    let relationshipPriority: Relationship
    let userId: String
    let username: String
    let email: String?
    let mostRecentPost: Post?
    let identifiableBy: String?

    var isCurrentUser : Bool

    init(avatarURL: NSURL?,
        coverImageURL: NSURL?,
        experimentalFeatures: Bool,
        followersCount: Int?,
        followingCount: Int?,
        href: String,
        name: String,
        posts: [Post],
        mostRecentPost: Post?,
        postsCount: Int?,
        relationshipPriority: Relationship,
        userId: String,
        username: String,
        email: String?,
        identifiableBy: String?,
        formattedShortBio: String,
        externalLinks: String,
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
        self.mostRecentPost = mostRecentPost
        self.isCurrentUser = isCurrentUser
        self.postsCount = postsCount
        self.relationshipPriority = relationshipPriority
        self.userId = userId
        self.username = username
        self.email = email
        self.identifiableBy = identifiableBy
        self.formattedShortBio = formattedShortBio
        self.externalLinks = externalLinks
    }

// MARK: NSCoding

    required init(coder decoder: NSCoder) {
        self.avatarURL = decoder.decodeObjectForKey("avatarURL") as? NSURL
        self.coverImageURL = decoder.decodeObjectForKey("coverImageURL") as? NSURL

        if decoder.containsValueForKey("experimentalFeatures") {
            self.experimentalFeatures = decoder.decodeBoolForKey("experimentalFeatures")
        }
        else {
            self.experimentalFeatures = false
        }

        if decoder.containsValueForKey("followersCount") {
            self.followersCount = Int(decoder.decodeIntForKey("followersCount"))
        }

        if decoder.containsValueForKey("followingCount") {
            self.followingCount = Int(decoder.decodeIntForKey("followingCount"))
        }

        self.href = decoder.decodeObjectForKey("href") as String
        self.name = decoder.decodeObjectForKey("name") as String

        if decoder.containsValueForKey("posts") {
            self.posts = decoder.decodeObjectForKey("posts") as [Post]
        }
        else {
            self.posts = [Post]()
        }

        if decoder.containsValueForKey("isCurrentUser") {
            self.isCurrentUser = decoder.decodeBoolForKey("isCurrentUser")
        }
        else {
            self.isCurrentUser = false
        }

        if decoder.containsValueForKey("mostRecentPost") {
            self.mostRecentPost = decoder.decodeObjectForKey("mostRecentPost") as? Post
        }

        if decoder.containsValueForKey("postsCount") {
            self.postsCount = Int(decoder.decodeIntForKey("postsCount"))
        }

        let relationshipPriorityString = decoder.decodeObjectForKey("relationshipPriority") as String
        self.relationshipPriority = Relationship(stringValue: relationshipPriorityString) ?? .None

        self.userId = decoder.decodeObjectForKey("userId") as String
        self.username = decoder.decodeObjectForKey("username") as String
        self.email = decoder.decodeObjectForKey("email") as? String
        self.formattedShortBio = decoder.decodeObjectForKey("formattedShortBio") as String
        self.externalLinks = decoder.decodeObjectForKey("externalLinks") as String
    }

    func encodeWithCoder(encoder: NSCoder) {

        encoder.encodeObject(self.avatarURL, forKey: "avatarURL")
        encoder.encodeObject(self.coverImageURL, forKey: "coverImageURL")
        encoder.encodeBool(self.experimentalFeatures, forKey: "experimentalFeatures")
        if let followersCount = self.followersCount {
            encoder.encodeInt64(Int64(followersCount), forKey: "followersCount")
        }

        if let followersCount = self.followingCount {
            encoder.encodeInt64(Int64(followersCount), forKey: "followingCount")
        }
        encoder.encodeObject(self.href, forKey: "href")
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.posts, forKey: "posts")
        if let mostRecentPost = self.mostRecentPost {
            encoder.encodeObject(mostRecentPost, forKey: "mostRecentPost")
        }
        encoder.encodeBool(self.isCurrentUser, forKey: "isCurrentUser")
        if let postsCount = self.postsCount {
            encoder.encodeInt64(Int64(postsCount), forKey: "postsCount")
        }
        encoder.encodeObject(self.relationshipPriority.rawValue, forKey: "relationshipPriority")
        encoder.encodeObject(self.userId, forKey: "userId")
        encoder.encodeObject(self.username, forKey: "username")
        self.email.map { encoder.encodeObject($0, forKey: "email") }
        encoder.encodeObject(self.formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(self.externalLinks, forKey: "externalLinks")
    }
    
// MARK: JSONAble

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let name = json["name"].stringValue
        let userId = json["id"].stringValue
        let username = json["username"].stringValue
        let email = json["email"].string
        let formattedShortBio = json["formatted_short_bio"].stringValue
        let externalLinks = json["external_links"].stringValue


        let experimentalFeatures = json["experimental_features"].boolValue
        let href = json["href"].stringValue
        let relationshipPriority = Relationship(stringValue: json["relationship_priority"].stringValue)

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
        var mostRecentPost: Post?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            if let posts = links["posts"] as? [Post] {
                userPosts = posts
            }
            mostRecentPost = links["most_recent_post"] as? Post
        }

        let identifiableBy = json["identifiable_by"].string

        let user = User(
            avatarURL: avatarURL,
            coverImageURL: coverImageURL,
            experimentalFeatures: experimentalFeatures,
            followersCount: followersCount,
            followingCount: followingCount,
            href: href,
            name: name,
            posts: userPosts,
            mostRecentPost: mostRecentPost,
            postsCount: postsCount,
            relationshipPriority: relationshipPriority,
            userId: userId,
            username: username,
            email: email,
            identifiableBy: identifiableBy,
            formattedShortBio: formattedShortBio,
            externalLinks: externalLinks
        )

        // hack back in author
        for post in user.posts {
            post.author = user
        }

        if let recentPost = user.mostRecentPost {
            recentPost.author = user
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
            mostRecentPost: nil,
            postsCount: 2,
            relationshipPriority: .Me,
            userId: "42",
            username: username,
            email: .None,
            identifiableBy: .None,
            formattedShortBio: "bio",
            externalLinks: "externalLinks"
        )
    }
}
