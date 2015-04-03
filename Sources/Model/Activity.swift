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

    public enum Kind: String {
        case OwnPost = "own_post" // main feed
        case FriendPost = "friend_post" // main feed
        case WelcomePost = "welcome_post" // main feed
        case NoisePost = "noise_post" // main feed

        // Notifications
        case RepostNotification = "repost_notification" // main feed (but collapsable)
        case NewFollowedUserPost = "new_followed_user_post" // main feed
        case NewFollowerPost = "new_follower_post"
        case PostMentionNotification = "post_mention_notification"
        case CommentMentionNotification = "comment_mention_notification"
        case InvitationAcceptedPost = "invitation_accepted_post"
        case CommentNotification = "comment_notification" // main feed
        case WelcomeNotification = "welcome_notification"
        case Unknown = "Unknown"

        static func allNotifications() -> [Kind] { return [.RepostNotification, .NewFollowedUserPost, .NewFollowerPost, .PostMentionNotification, .CommentMentionNotification, .InvitationAcceptedPost, .CommentNotification, .WelcomeNotification]}
        static func commentNotifications() -> [Kind] { return [.CommentNotification]}
        static func mentionNotifications() -> [Kind] { return [.PostMentionNotification, .CommentMentionNotification]}
        static func repostNotifications() -> [Kind] { return [.RepostNotification]}
        static func relationshipNotifications() -> [Kind] { return [.NewFollowerPost, .NewFollowedUserPost]}
    }

    public enum SubjectType: String {
        case Post = "Post"
        case User = "User"
        case Unknown = "Unknown"
    }

    public let version: Int = ActivityVersion
    public let activityId: String
    public let kind: Kind
    public let subjectType: SubjectType
    public var subject: AnyObject?
    public let createdAt: NSDate

// MARK: Initialization

    public init(activityId: String,
        kind: Kind,
        subjectType: SubjectType,
        subject: AnyObject?,
        createdAt: NSDate )
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
        let kindString: String = decoder.decodeKey("kind")
        self.kind = Kind(rawValue: kindString) ?? Kind.Unknown
        self.activityId = decoder.decodeKey("activityId")
        let subjectTypeString: String = decoder.decodeKey("subjectType")
        self.subjectType = SubjectType(rawValue: subjectTypeString) ?? SubjectType.Unknown
        self.subject = decoder.decodeOptionalKey("subject")
        self.createdAt = decoder.decodeKey("createdAt")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.kind.rawValue, forKey: "kind")
        encoder.encodeObject(self.activityId, forKey: "activityId")
        encoder.encodeObject(self.subjectType.rawValue, forKey: "subjectType")
        if let subject: AnyObject = self.subject {
            encoder.encodeObject(subject, forKey: "subject")
        }
        encoder.encodeObject(self.createdAt, forKey: "createdAt")
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let sub = json["subject"]
        let kind = Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown
        let activityId = json["created_at"].stringValue
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
