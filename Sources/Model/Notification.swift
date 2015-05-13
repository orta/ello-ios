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

public final class Notification: JSONAble, Authorable {

    // required
    public let activity: Activity
    // optional
    public var author: User?
    // computed
    public var createdAt: NSDate { return activity.createdAt }
    public var groupId:String { return activity.id }
    public var subject: AnyObject? { willSet { attributedTitleStore = nil } }

    // notification specific
    public var textRegion: TextRegion?
    public var imageRegion: ImageRegion?
    private var attributedTitleStore: NSAttributedString? = nil
    public var attributedTitle: NSAttributedString {
        if let attributedTitle = attributedTitleStore {
            return attributedTitle
        }
        attributedTitleStore = NotificationAttributedTitle.attributedTitle(activity.kind, author: author, subject: subject)
        return attributedTitleStore!
    }

// MARK: Initialization

    public init(activity: Activity) {
        self.activity = activity
        var author : User? = nil
        if let post = activity.subject as? Post {
            self.author = post.author
        }
        else if let comment = activity.subject as? Comment {
            self.author = comment.author
        }
        else if let user = activity.subject as? User {
            self.author = user
        }
        super.init(version: NotificationVersion)
        if let post = activity.subject as? Post {
            assignRegionsFromContent(post.summary)
        }
        else if let comment = activity.subject as? Comment {
            assignRegionsFromContent(comment.content)
        }
        subject = activity.subject
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.activity = decoder.decodeKey("activity")
        self.author = decoder.decodeOptionalKey("author")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(activity, forKey: "activity")
        coder.encodeObject(author, forKey: "author")
        super.encodeWithCoder(coder.coder)
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
