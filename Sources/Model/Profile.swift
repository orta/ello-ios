//
//  Profile.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let ProfileVersion: Int = 1

public final class Profile: JSONAble, Userlike, NSCoding {
    public let version = ProfileVersion

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let href: String
    public let username: String
    public let name: String
    public let experimentalFeatures: Bool
    public let relationshipPriority: Relationship
    public let postsCount: Int
    public let followersCount: Int
    public let followingCount: Int
    public let formattedShortBio: String
    public let externalLinks: String // this will change to an object when incoming
    public let backgroundPosition: String
    public let shortBio: String
    public let externalLinksList: [String]
    public let email: String
    public let confirmedAt: NSDate
    public let isPublic: Bool
    public let hasCommentingEnabled: Bool
    public let hasSharingEnabled: Bool
    public let hasRepostingEnabled: Bool
    public let hasAdNotificationsEnabled: Bool
    public let allowsAnalytics: Bool
    public let postsAdultContent: Bool
    public let viewsAdultContent: Bool
    public let notifyOfCommentsViaEmail: Bool
    public let notifyOfInvitationAcceptancesViaEmail: Bool
    public let notifyOfMentionsViaEmail: Bool
    public let notifyOfNewFollowersViaEmail: Bool
    public let subscribeToUsersEmailList: Bool
    // optional
    public var avatar: ImageAttachment? // required, but kinda optional due to it being nested in json
    public var coverImage: ImageAttachment? // required, but kinda optional due to it being nested in json
    // links
    public var posts: [Post]?
    public var mostRecentPost: Post?
    // other
    public let isCurrentUser = true
    // computed
    public var atName: String { return "@\(username)"}
    public var avatarURL: NSURL? { return avatar?.url }
    public var coverImageURL: NSURL? { return coverImage?.url }

    public init(id: String,
        createdAt: NSDate,
        href: String,
        username: String,
        name: String,
        experimentalFeatures: Bool,
        relationshipPriority: Relationship,
        postsCount: Int,
        followersCount: Int,
        followingCount: Int,
        formattedShortBio: String,
        externalLinks: String,
        backgroundPosition: String,
        shortBio: String,
        externalLinksList: [String],
        email: String,
        confirmedAt: NSDate,
        isPublic: Bool,
        hasCommentingEnabled: Bool,
        hasSharingEnabled: Bool,
        hasRepostingEnabled: Bool,
        hasAdNotificationsEnabled: Bool,
        allowsAnalytics: Bool,
        postsAdultContent: Bool,
        viewsAdultContent: Bool,
        notifyOfCommentsViaEmail: Bool,
        notifyOfInvitationAcceptancesViaEmail: Bool,
        notifyOfMentionsViaEmail: Bool,
        notifyOfNewFollowersViaEmail: Bool,
        subscribeToUsersEmailList: Bool)
    {
        self.id = id
        self.createdAt = createdAt
        self.href = href
        self.username = username
        self.name = name
        self.experimentalFeatures = experimentalFeatures
        self.relationshipPriority = relationshipPriority
        self.postsCount = postsCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.formattedShortBio = formattedShortBio
        self.externalLinks = externalLinks
        self.backgroundPosition = backgroundPosition
        self.shortBio = shortBio
        self.externalLinksList = externalLinksList
        self.email = email
        self.confirmedAt = confirmedAt
        self.isPublic = isPublic
        self.hasCommentingEnabled = hasCommentingEnabled
        self.hasSharingEnabled = hasSharingEnabled
        self.hasRepostingEnabled = hasRepostingEnabled
        self.hasAdNotificationsEnabled = hasAdNotificationsEnabled
        self.allowsAnalytics = allowsAnalytics
        self.postsAdultContent = postsAdultContent
        self.viewsAdultContent = viewsAdultContent
        self.notifyOfCommentsViaEmail = notifyOfCommentsViaEmail
        self.notifyOfInvitationAcceptancesViaEmail = notifyOfInvitationAcceptancesViaEmail
        self.notifyOfMentionsViaEmail = notifyOfMentionsViaEmail
        self.notifyOfNewFollowersViaEmail = notifyOfNewFollowersViaEmail
        self.subscribeToUsersEmailList = subscribeToUsersEmailList
    }

// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.href = decoder.decodeKey("href")
        self.username = decoder.decodeKey("username")
        self.name = decoder.decodeKey("name")
        self.avatar = decoder.decodeKey("avatar")
        self.experimentalFeatures = decoder.decodeKey("experimentalFeatures")
        let relationshipPriorityRaw: String = decoder.decodeKey("relationshipPriorityRaw")
        self.relationshipPriority = Relationship(stringValue: relationshipPriorityRaw)
        self.postsCount = decoder.decodeKey("postsCount")
        self.followersCount = decoder.decodeKey("followersCount")
        self.followingCount = decoder.decodeKey("followingCount")
        self.formattedShortBio = decoder.decodeKey("formattedShortBio")
        self.externalLinks = decoder.decodeKey("externalLinks")
        self.coverImage = decoder.decodeOptionalKey("coverImage")
        self.backgroundPosition = decoder.decodeKey("backgroundPosition")
        self.shortBio = decoder.decodeKey("shortBio")
        self.externalLinksList = decoder.decodeKey("externalLinksList")
        self.email = decoder.decodeKey("email")
        self.confirmedAt = decoder.decodeKey("confirmedAt")
        self.isPublic = decoder.decodeKey("isPublic")
        self.hasCommentingEnabled = decoder.decodeKey("hasCommentingEnabled")
        self.hasSharingEnabled = decoder.decodeKey("hasSharingEnabled")
        self.hasRepostingEnabled = decoder.decodeKey("hasRepostingEnabled")
        self.hasAdNotificationsEnabled = decoder.decodeKey("hasAdNotificationsEnabled")
        self.allowsAnalytics = decoder.decodeKey("allowsAnalytics")
        self.postsAdultContent = decoder.decodeKey("postsAdultContent")
        self.viewsAdultContent = decoder.decodeKey("viewsAdultContent")
        self.notifyOfCommentsViaEmail = decoder.decodeKey("notifyOfCommentsViaEmail")
        self.notifyOfInvitationAcceptancesViaEmail = decoder.decodeKey("notifyOfInvitationAcceptancesViaEmail")
        self.notifyOfMentionsViaEmail = decoder.decodeKey("notifyOfMentionsViaEmail")
        self.notifyOfNewFollowersViaEmail = decoder.decodeKey("notifyOfNewFollowersViaEmail")
        self.subscribeToUsersEmailList = decoder.decodeKey("subscribeToUsersEmailList")
        // links
        self.posts = decoder.decodeOptionalKey("posts")
        self.mostRecentPost = decoder.decodeOptionalKey("mostRecentPost")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        // required
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(username, forKey: "username")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(avatar, forKey: "avatar")
        encoder.encodeBool(experimentalFeatures, forKey: "experimentalFeatures")
        encoder.encodeObject(relationshipPriority.rawValue, forKey: "relationshipPriorityRaw")
        encoder.encodeInt64(Int64(postsCount), forKey: "postsCount")
        encoder.encodeInt64(Int64(followersCount), forKey: "followersCount")
        encoder.encodeInt64(Int64(followingCount), forKey: "followingCount")
        encoder.encodeObject(formattedShortBio, forKey: "formattedShortBio")
        encoder.encodeObject(externalLinks, forKey: "externalLinks")
        encoder.encodeObject(coverImage, forKey: "coverImage")
        encoder.encodeObject(backgroundPosition, forKey: "backgroundPosition")
        encoder.encodeObject(shortBio, forKey: "shortBio")
        encoder.encodeObject(externalLinksList, forKey: "externalLinksList")
        encoder.encodeObject(email, forKey: "email")
        encoder.encodeObject(confirmedAt, forKey: "confirmedAt")
        encoder.encodeBool(isPublic, forKey: "isPublic")
        encoder.encodeBool(hasCommentingEnabled, forKey: "hasCommentingEnabled")
        encoder.encodeBool(hasSharingEnabled, forKey: "hasSharingEnabled")
        encoder.encodeBool(hasRepostingEnabled, forKey: "hasRepostingEnabled")
        encoder.encodeBool(hasAdNotificationsEnabled, forKey: "hasAdNotificationsEnabled")
        encoder.encodeBool(allowsAnalytics, forKey: "allowsAnalytics")
        encoder.encodeBool(postsAdultContent, forKey: "postsAdultContent")
        encoder.encodeBool(viewsAdultContent, forKey: "viewsAdultContent")
        encoder.encodeBool(notifyOfCommentsViaEmail, forKey: "notifyOfCommentsViaEmail")
        encoder.encodeBool(notifyOfInvitationAcceptancesViaEmail, forKey: "notifyOfInvitationAcceptancesViaEmail")
        encoder.encodeBool(notifyOfMentionsViaEmail, forKey: "notifyOfMentionsViaEmail")
        encoder.encodeBool(notifyOfNewFollowersViaEmail, forKey: "notifyOfNewFollowersViaEmail")
        encoder.encodeBool(subscribeToUsersEmailList, forKey: "subscribeToUsersEmailList")
        // links
        encoder.encodeObject(posts, forKey: "posts")
        encoder.encodeObject(mostRecentPost, forKey: "mostRecentPost")
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        // create profile
        var profile = Profile(
            id: json["id"].stringValue,
            createdAt: (json["created_at"].stringValue.toNSDate() ?? NSDate()),
            href: json["href"].stringValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            experimentalFeatures: json["experimental_features"].boolValue,
            relationshipPriority: Relationship(stringValue: json["relationship_priority"].stringValue),
            postsCount: json["posts_count"].int ?? 0,
            followersCount: json["followers_count"].int ?? 0,
            followingCount: json["following_count"].int ?? 0,
            formattedShortBio: json["formatted_short_bio"].stringValue,
            externalLinks: json["external_links"].stringValue,
            backgroundPosition: json["background_position"].stringValue,
            shortBio: json["short_bio"].stringValue,
            externalLinksList: ["yo"],
            email: json["email"].stringValue,
            confirmedAt: (json["confirmed_at"].stringValue.toNSDate() ?? NSDate()),
            isPublic: json["is_public"].boolValue,
            hasCommentingEnabled: json["has_commenting_enabled"].boolValue,
            hasSharingEnabled: json["has_sharing_enabled"].boolValue,
            hasRepostingEnabled: json["has_reposting_enabled"].boolValue,
            hasAdNotificationsEnabled: json["has_ad_notifications_enabled"].boolValue,
            allowsAnalytics: json["allows_analytics"].boolValue,
            postsAdultContent: json["posts_adult_content"].boolValue,
            viewsAdultContent: json["views_adult_content"].boolValue,
            notifyOfCommentsViaEmail: json["notify_of_comments_via_email"].boolValue,
            notifyOfInvitationAcceptancesViaEmail: json["notify_of_invitation_acceptances_via_email"].boolValue,
            notifyOfMentionsViaEmail: json["notify_of_mentions_via_email"].boolValue,
            notifyOfNewFollowersViaEmail: json["notify_of_new_followers_via_email"].boolValue,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].boolValue
        )

        if let avatarObj = json["avatar"].object as? [String:[String:AnyObject]] {
            if let avatarPath = avatarObj["large"]?["url"] as? String {
                profile.avatar = ImageAttachment(url: NSURL(string: avatarPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
        }
        if var coverImageObj = json["cover_image"].object as? [String:[String:AnyObject]] {
            if let coverPath = coverImageObj["hdpi"]?["url"] as? String {
                profile.coverImage = ImageAttachment(url: NSURL(string: coverPath, relativeToURL: NSURL(string: ElloURI.baseURL)), height: 0, width: 0, imageType: "png", size: 0)
            }
        }
        // links
        if let linksNode = data["links"] as? [String: AnyObject] {
            let links = ElloLinkedStore.parseLinks(linksNode)
            profile.posts = links["posts"] as? [Post]
            profile.mostRecentPost = links["most_recent_post"] as? Post
        }
        // hack back in author
        if let posts = profile.posts {
            for post in posts {
                post.author = profile
            }
        }
        if let recentPost = profile.mostRecentPost {
            recentPost.author = profile
        }
        return profile
    }
}

