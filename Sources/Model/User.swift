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

let UserVersion: Int = 1

public final class User: JSONAble {

    // active record
    public let id: String
    // required
    public let href: String
    public let username: String
    public let name: String
    public let experimentalFeatures: Bool
    public var relationshipPriority: RelationshipPriority
    public let postsAdultContent: Bool
    public let viewsAdultContent: Bool
    public let hasCommentingEnabled: Bool
    public let hasSharingEnabled: Bool
    public let hasRepostingEnabled: Bool
    // optional
    public var avatar: Asset? // required, but kinda optional due to it being nested in json
    public var identifiableBy: String?
    public var postsCount: Int?
    public var followersCount: String? // string due to this returning "∞" for the ello user
    public var followingCount: Int?
    public var formattedShortBio: String?
    public var externalLinks: String? // this will change to an object when incoming
    public var coverImage: Asset?
    public var backgroundPosition: String?
    // links
    public var posts: [Post]? { return getLinkArray("posts") as? [Post] }
    public var mostRecentPost: Post? { return getLinkObject("most_recent_post") as? Post }
    // computed
    public var atName: String { return "@\(username)"}
    public var avatarURL: NSURL? { return avatar?.regular?.url }
    public var coverImageURL: NSURL? { return coverImage?.hdpi?.url }
    public var isCurrentUser: Bool { return self.profile != nil }
    // profile
    public var profile: Profile?

    public init(id: String,
        href: String,
        username: String,
        name: String,
        experimentalFeatures: Bool,
        relationshipPriority: RelationshipPriority,
        postsAdultContent: Bool,
        viewsAdultContent: Bool,
        hasCommentingEnabled: Bool,
        hasSharingEnabled: Bool,
        hasRepostingEnabled: Bool)
    {
        self.id = id
        self.href = href
        self.username = username
        self.name = name
        self.experimentalFeatures = experimentalFeatures
        self.relationshipPriority = relationshipPriority
        self.postsAdultContent = postsAdultContent
        self.viewsAdultContent = viewsAdultContent
        self.hasCommentingEnabled = hasCommentingEnabled
        self.hasSharingEnabled = hasSharingEnabled
        self.hasRepostingEnabled = hasRepostingEnabled
        super.init(version: UserVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        // required
        self.href = decoder.decodeKey("href")
        self.username = decoder.decodeKey("username")
        self.name = decoder.decodeKey("name")
        self.experimentalFeatures = decoder.decodeKey("experimentalFeatures")
        let relationshipPriorityRaw: String = decoder.decodeKey("relationshipPriorityRaw")
        self.relationshipPriority = RelationshipPriority(stringValue: relationshipPriorityRaw)
        self.postsAdultContent = decoder.decodeKey("postsAdultContent")
        self.viewsAdultContent = decoder.decodeKey("viewsAdultContent")
        self.hasCommentingEnabled = decoder.decodeKey("hasCommentingEnabled")
        self.hasSharingEnabled = decoder.decodeKey("hasSharingEnabled")
        self.hasRepostingEnabled = decoder.decodeKey("hasRepostingEnabled")
        // optional
        self.avatar = decoder.decodeOptionalKey("avatar")
        self.identifiableBy = decoder.decodeOptionalKey("identifiableBy")
        self.postsCount = decoder.decodeOptionalKey("postsCount")
        self.followersCount = decoder.decodeOptionalKey("followersCount")
        self.followingCount = decoder.decodeOptionalKey("followingCount")
        self.formattedShortBio = decoder.decodeOptionalKey("formattedShortBio")
        self.externalLinks = decoder.decodeOptionalKey("externalLinks")
        self.coverImage = decoder.decodeOptionalKey("coverImage")
        self.backgroundPosition = decoder.decodeOptionalKey("backgroundPosition")
        // profile
        self.profile = decoder.decodeOptionalKey("profile")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        // required
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(username, forKey: "username")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeBool(experimentalFeatures, forKey: "experimentalFeatures")
        encoder.encodeObject(relationshipPriority.rawValue, forKey: "relationshipPriorityRaw")
        encoder.encodeBool(postsAdultContent, forKey: "postsAdultContent")
        encoder.encodeBool(viewsAdultContent, forKey: "viewsAdultContent")
        encoder.encodeBool(hasCommentingEnabled, forKey: "hasCommentingEnabled")
        encoder.encodeBool(hasSharingEnabled, forKey: "hasSharingEnabled")
        encoder.encodeBool(hasRepostingEnabled, forKey: "hasRepostingEnabled")
        // optional
        encoder.encodeObject(avatar, forKey: "avatar")
        encoder.encodeObject(identifiableBy, forKey: "identifiableBy")
        if let postsCount = self.postsCount {
            encoder.encodeInt64(Int64(postsCount), forKey: "postsCount")
        }
        encoder.encodeObject(followersCount, forKey: "followersCount")
        if let followingCount = self.followingCount {
            encoder.encodeInt64(Int64(followingCount), forKey: "followingCount")
        }
        encoder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(externalLinks, forKey: "externalLinks")
        encoder.encodeObject(coverImage, forKey: "coverImage")
        encoder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        // profile
        encoder.encodeObject(profile, forKey: "profile")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)

        // create user
        var user = User(
            id: json["id"].stringValue,
            href: json["href"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            experimentalFeatures: json["experimental_features"].boolValue,
            relationshipPriority: RelationshipPriority(stringValue: json["relationship_priority"].stringValue),
            postsAdultContent: json["posts_adult_content"].boolValue,
            viewsAdultContent: json["views_adult_content"].boolValue,
            hasCommentingEnabled: json["has_commenting_enabled"].boolValue,
            hasSharingEnabled: json["has_sharing_enabled"].boolValue,
            hasRepostingEnabled: json["has_reposting_enabled"].boolValue
        )

        // optional
        user.avatar = Asset.parseAsset("user_avatar_\(user.id)", node: data["avatar"] as? [String: AnyObject])
        user.identifiableBy = json["identifiable_by"].stringValue
        user.postsCount = json["posts_count"].int
        user.followersCount = json["followers_count"].stringValue
        user.followingCount = json["following_count"].int
        user.formattedShortBio = json["formatted_short_bio"].stringValue
        user.externalLinks = json["external_links"].stringValue
        user.coverImage = Asset.parseAsset("user_cover_image_\(user.id)", node: data["cover_image"] as? [String: AnyObject])
        user.backgroundPosition = json["background_positiion"].stringValue
        // links
        user.links = data["links"] as? [String: AnyObject]
        // profile
        if count(json["created_at"].stringValue) > 0 {
            user.profile = Profile.fromJSON(data) as? Profile
        }
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(user, forKey: user.id, inCollection: MappingType.UsersType.rawValue)
        }
        return user
    }
}

extension User {
    func propertyForSettingsKey(key: String) -> Bool {
        var value: Bool? = false
        if respondsToSelector(Selector(key.camelCase)) {
            value = valueForKey(key.camelCase) as? Bool
        } else if profile?.respondsToSelector(Selector(key.camelCase)) ?? false {
            value = profile?.valueForKey(key.camelCase) as? Bool
        }
        return value ?? false
    }
}
