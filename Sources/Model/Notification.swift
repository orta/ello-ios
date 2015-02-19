//
//  Notification.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


struct Attributed {
    static let Link : NSString = "ElloLinkAttributedString"
}

class Notification : JSONAble, Authorable {
    struct TitleStyles {
        static func attrs(_ addl : [String : AnyObject] = [:]) -> [NSObject : AnyObject] {
            var attrs : [String : AnyObject] = [
                NSFontAttributeName : UIFont.typewriterFont(12),
            ]
            return attrs + addl
        }
        static func text(text : String) -> NSAttributedString {
            return NSAttributedString(string: text, attributes: attrs())
        }
        static func profile(text : String, _ id : String) -> NSAttributedString {
            return NSAttributedString(string: text, attributes: attrs([
                Attributed.Link : "profile/\(id)",
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        static func post(text : String, _ id : String) -> NSAttributedString {
            var attrs = TitleStyles.attrs([
                Attributed.Link : "post/\(id)",
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ])
            return NSAttributedString(string: text, attributes: attrs)
        }
        static func comment(text : String, _ id : String) -> NSAttributedString {
            var attrs = TitleStyles.attrs([
                Attributed.Link : "comment/\(id)",
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ])
            return NSAttributedString(string: text, attributes: attrs)
        }
    }
    typealias Kind = Activity.Kind
    typealias SubjectType = Activity.SubjectType

    var author: User?
    var createdAt: NSDate
    var groupId:String { return notificationId }
    let notificationId: String
    let kind: Kind
    let subjectType: SubjectType
    var subject: AnyObject?

    var attributedTitle: NSAttributedString {
        switch kind {
            case .RepostNotification:         return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" reposted your ")).append(TitleStyles.post("post", "id")).append(TitleStyles.text("."))
            case .NewFollowedUserPost:        return TitleStyles.text("You started following ").append(TitleStyles.profile(author!.atName, author!.userId)).append(TitleStyles.text("."))
            case .NewFollowerPost:            return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" started following you."))
            case .PostMentionNotification:    return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.post("post", "id")).append(TitleStyles.text("."))
            case .CommentMentionNotification: return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.comment("comment", "id")).append(TitleStyles.text("."))
            case .InvitationAcceptedPost:     return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" accepted your invitation."))
            case .CommentNotification:        return TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" commented on your ")).append(TitleStyles.post("post", "id")).append(TitleStyles.text("."))
            case .WelcomeNotification:        return TitleStyles.text("Welcome to Ello!")
            default: return NSAttributedString(string: "")
        }
    }
    var textRegion: TextRegion?
    var imageRegion: ImageRegion?

    convenience init(activity: Activity) {
        self.init(createdAt: activity.createdAt, kind: activity.kind, notificationId: activity.activityId, subjectType: activity.subjectType)
        if let post = activity.subject as? Post {
            self.author = post.author
            self.assignRegionsFromContent(post.summary!)
        }
        else if let comment = activity.subject as? Comment {
            self.author = comment.author
            self.assignRegionsFromContent(comment.summary!)
        }
        else if let user = activity.subject as? User {
            self.author = user
        }
        self.subject = activity.subject
    }

    required init(createdAt: NSDate, kind: Kind, notificationId: String, subjectType: SubjectType) {
        self.createdAt = createdAt
        self.kind = kind
        self.notificationId = notificationId
        self.subjectType = subjectType
        super.init()
    }

    func hasImage() -> Bool {
        return self.imageRegion != nil
    }

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