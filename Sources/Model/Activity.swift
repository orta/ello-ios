//
//  Activity.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON

let ActivityVersion = 1

public final class Activity: JSONAble, NSCoding {
    public let version: Int = ActivityVersion

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

    public let activityId: String
    // required
    public let kind: Kind
    public let subjectType: SubjectType
    public let createdAt: NSDate
    // links
    public var subject: AnyObject?

// MARK: Initialization

    public init(activityId: String,
        kind: Kind,
        subjectType: SubjectType,
        subject: AnyObject?,
        createdAt: NSDate)
    {
        self.activityId = activityId
        self.kind = kind
        self.subjectType = subjectType
        self.subject = subject
        self.createdAt = createdAt
    }

// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.activityId = decoder.decodeKey("activityId")
        let kindString: String = decoder.decodeKey("kind")
        self.kind = Kind(rawValue: kindString) ?? Kind.Unknown
        self.createdAt = decoder.decodeKey("createdAt")
        let subjectTypeString: String = decoder.decodeKey("subjectType")
        self.subjectType = SubjectType(rawValue: subjectTypeString) ?? SubjectType.Unknown
        self.subject = decoder.decodeOptionalKey("subject")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.activityId, forKey: "activityId")
        encoder.encodeObject(self.kind.rawValue, forKey: "kind")
        encoder.encodeObject(self.createdAt, forKey: "createdAt")
        encoder.encodeObject(self.subjectType.rawValue, forKey: "subjectType")
        if let subject: AnyObject = self.subject {
            encoder.encodeObject(subject, forKey: "subject")
        }
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let activityId = json["created_at"].stringValue
        let kind = Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown
        let subjectType = SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.Unknown
        var createdAt = json["created_at"].stringValue.toNSDate() ?? NSDate()

        var links = [String: AnyObject]()
        var subject:AnyObject?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            subject = links["subject"]
        }

        return Activity(
            activityId: activityId,
            kind: kind,
            subjectType: subjectType,
            subject: subject,
            createdAt: createdAt
        )
    }
}
