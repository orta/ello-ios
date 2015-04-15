//
//  Notification.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


public enum NotificationFilterType: String {
    case All = "NotificationFilterTypeAll"
    case Misc = "NotificationFilterTypeMisc"
    case Mention = "NotificationFilterTypeMention"
    case Heart = "NotificationFilterTypeHeart"
    case Repost = "NotificationFilterTypeRepost"
    case Relationship = "NotificationFilterTypeRelationship"
}

let NotificationVersion = 1

public final class Notification : JSONAble, Authorable {
    public let version: Int = NotificationVersion

    public typealias Kind = Activity.Kind
    public typealias SubjectType = Activity.SubjectType

    // required
    public let kind: Kind
    public let subjectType: SubjectType
    public var createdAt: NSDate

    public let author: User?
    public var groupId:String { return notificationId }
    public let notificationId: String
    public var subject: AnyObject? { willSet { attributedTitleStore = nil } }

    public var textRegion: TextRegion?
    public var imageRegion: ImageRegion?

    private var attributedTitleStore: NSAttributedString?
    public var attributedTitle: NSAttributedString {
        if let attributedTitle = attributedTitleStore {
            return attributedTitle
        }

        attributedTitleStore = NotificationAttributedTitle.attributedTitle(kind, author: author, subject: subject)
        return attributedTitleStore!
    }

// MARK: Initialization

    convenience public init(activity: Activity) {
        var author : User? = nil
        if let post = activity.subject as? Post {
            author = post.author
        }
        else if let comment = activity.subject as? Comment {
            author = comment.author
        }
        else if let user = activity.subject as? User {
            author = user
        }

        self.init(author: author, createdAt: activity.createdAt, kind: activity.kind, notificationId: activity.id, subjectType: activity.subjectType)
        if let post = activity.subject as? Post {
            self.assignRegionsFromContent(post.summary)
        }
        else if let comment = activity.subject as? Comment {
            self.assignRegionsFromContent(comment.content)
        }
        self.subject = activity.subject
    }

    public init(author: User?, createdAt: NSDate, kind: Kind, notificationId: String, subjectType: SubjectType) {
        self.author = author
        self.attributedTitleStore = nil
        self.createdAt = createdAt
        self.kind = kind
        self.notificationId = notificationId
        self.subjectType = subjectType
        super.init()
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.author = decoder.decodeOptionalKey("author")
        self.createdAt = decoder.decodeKey("createdAt")
        let kindString: String = decoder.decodeKey("kind")
        self.kind = Kind(rawValue: kindString) ?? Kind.Unknown
        self.notificationId = decoder.decodeKey("notificationId")
        let subjectTypeString: String = decoder.decodeKey("subjectType")
        self.subjectType = SubjectType(rawValue: subjectTypeString) ?? SubjectType.Unknown
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        if let author = self.author {
            encoder.encodeObject(author, forKey: "author")
        }
        encoder.encodeObject(self.createdAt, forKey: "createdAt")
        encoder.encodeObject(self.kind.rawValue, forKey: "kind")
        encoder.encodeObject(self.notificationId, forKey: "notificationId")
        encoder.encodeObject(self.subjectType.rawValue, forKey: "subjectType")
        super.encodeWithCoder(encoder)
    }

// MARK: Public

    func hasImage() -> Bool {
        return self.imageRegion != nil
    }

// MARK: Private

    private func assignRegionsFromContent(content : [Regionable]) {
        // assign textRegion and imageRegion from the post content - finds
        // the first of both kinds of regions
        for region in content {
            if self.textRegion != nil && self.imageRegion != nil {
                break
            }
            else if let textRegion = region as? TextRegion {
                if self.textRegion == nil {
                    self.textRegion = textRegion
                }
            }
            else if let imageRegion = region as? ImageRegion {
                if self.imageRegion == nil {
                    self.imageRegion = imageRegion
                }
            }
        }
    }
}
