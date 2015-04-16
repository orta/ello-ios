//
//  Activity.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON

let ActivityVersion = 1

public final class Activity: JSONAble {
    public let version = ActivityVersion

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let kind: Kind
    public let subjectType: SubjectType
    // links
    public var subject: JSONAble? { return getLinkObject("subject") }

    public enum Kind: String {
        // Posts
        case FriendPost = "friend_post" // main feed
        case OwnPost = "own_post" // main feed
        case WelcomePost = "welcome_post" // main feed
        case NoisePost = "noise_post" // main feed

        // Comments
        case FriendComment = "friend_comment"

        // Notifications
        case NewFollowerPost = "new_follower_post" // '#{name} started following you'
        case NewFollowedUserPost = "new_followed_user_post" // 'you started following #{name}'
        case InvitationAcceptedPost = "invitation_accepted_post" // '#{name} accepted your invitation'

        case PostMentionNotification = "post_mention_notification" // 'you were mentioned in a post'
        case CommentMentionNotification = "comment_mention_notification" // 'you were mentioned in a comment'
        case CommentNotification = "comment_notification" // 'someone commented on your post'
        case WelcomeNotification = "welcome_notification" // 'welcome to Ello'
        case RepostNotification = "repost_notification" // main feed (but collapsable) 'someone reposted your post'

        // Deprecated posts
        case CommentMention = "comment_mention"

        // Fallback for not defined types
        case Unknown = "Unknown"

        // Static funcs
        static func friendStreamKind() -> [Kind] { return [.FriendPost, .OwnPost, .WelcomePost] }
        static func noiseStreamKind() -> [Kind] { return [.NoisePost] }
        static func notificationStreamKind() -> [Kind] { return [.NewFollowerPost, .NewFollowedUserPost, .InvitationAcceptedPost, .PostMentionNotification, .CommentMentionNotification, .CommentNotification, .WelcomeNotification, .RepostNotification] }

        // Notification categories
        static func allNotifications() -> [Kind] { return notificationStreamKind() }
        static func commentNotifications() -> [Kind] { return [.CommentNotification] }
        static func mentionNotifications() -> [Kind] { return [.PostMentionNotification, .CommentMentionNotification] }
        static func repostNotifications() -> [Kind] { return [.RepostNotification]}
        static func relationshipNotifications() -> [Kind] { return [.NewFollowerPost, .NewFollowedUserPost] }
    }

    public enum SubjectType: String {
        case User = "User"
        case Post = "Post"
        case Comment = "Comment"
        case Unknown = "Unknown"
    }

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        kind: Kind,
        subjectType: SubjectType)
    {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.subjectType = subjectType
        super.init()
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        let rawKind: String = decoder.decodeKey("rawKind")
        self.kind = Kind(rawValue: rawKind) ?? Kind.Unknown
        let rawSubjectType: String = decoder.decodeKey("rawSubjectType")
        self.subjectType = SubjectType(rawValue: rawSubjectType) ?? SubjectType.Unknown
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(kind.rawValue, forKey: "rawKind")
        encoder.encodeObject(subjectType.rawValue, forKey: "rawSubjectType")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        // active record
        let id = json["created_at"].stringValue
        let createdAt = id.toNSDate()!
        // create activity
        var activity = Activity(
            id: id,
            createdAt: createdAt,
            kind: Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown,
            subjectType: SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.Unknown
        )
        // links
        activity.links = data["links"] as? [String: AnyObject]
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(activity, forKey: activity.id, inCollection: MappingType.ActivitiesType.rawValue)
        }
        return activity
    }
}
