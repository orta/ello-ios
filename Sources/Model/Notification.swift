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
    static let Object : NSString = "ElloObjectAttributedString"
}

class Notification : JSONAble, Authorable {
    struct TitleStyles {
        static func attrs(_ addlAttrs : [String : AnyObject] = [:]) -> [NSObject : AnyObject] {
            let attrs : [String : AnyObject] = [
                NSFontAttributeName : UIFont.typewriterFont(12),
                NSForegroundColorAttributeName : UIColor.greyA(),
            ]
            return attrs + addlAttrs
        }
        static func text(text : String) -> NSAttributedString {
            return NSAttributedString(string: text, attributes: attrs())
        }
        static func profile(text : String, _ user : User) -> NSAttributedString {
            return NSAttributedString(string: text, attributes: attrs([
                Attributed.Link : "user",
                Attributed.Object : user,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        static func post(text : String, _ post : Post) -> NSAttributedString {
            var attrs = TitleStyles.attrs([
                Attributed.Link : "post",
                Attributed.Object : post,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ])
            return NSAttributedString(string: text, attributes: attrs)
        }
        static func comment(text : String, _ comment : Comment) -> NSAttributedString {
            var attrs = TitleStyles.attrs([
                Attributed.Link : "comment",
                Attributed.Object : comment,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ])
            return NSAttributedString(string: text, attributes: attrs)
        }
    }
    typealias Kind = Activity.Kind
    typealias SubjectType = Activity.SubjectType

    let author: User?
    var createdAt: NSDate
    var groupId:String { return notificationId }
    let notificationId: String
    let kind: Kind
    let subjectType: SubjectType
    var subject: AnyObject? { willSet { attributedTitleStore = nil } }

    private var attributedTitleStore: NSAttributedString?
    var attributedTitle: NSAttributedString {
        if let attributedTitle = attributedTitleStore {
            return attributedTitle
        }

        switch kind {
            case .RepostNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" reposted your ")).append(TitleStyles.post("post", subject! as Post)).append(TitleStyles.text("."))
            case .NewFollowedUserPost:
                attributedTitleStore = TitleStyles.text("You started following ").append(TitleStyles.profile(author!.atName, author!)).append(TitleStyles.text("."))
            case .NewFollowerPost:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" started following you."))
            case .PostMentionNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.post("post", subject! as Post)).append(TitleStyles.text("."))
            case .CommentMentionNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.comment("comment", subject! as Comment)).append(TitleStyles.text("."))
            case .InvitationAcceptedPost:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" accepted your invitation."))
            case .CommentNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!).append(TitleStyles.text(" commented on your ")).append(TitleStyles.comment("post", subject! as Comment)).append(TitleStyles.text("."))
            case .WelcomeNotification:
                attributedTitleStore = TitleStyles.text("Welcome to Ello!")
            default:
                attributedTitleStore = NSAttributedString(string: "")
        }

        return attributedTitleStore!
    }
    var textRegion: TextRegion?
    var imageRegion: ImageRegion?

    convenience init(activity: Activity) {
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

        self.init(author: author, createdAt: activity.createdAt, kind: activity.kind, notificationId: activity.activityId, subjectType: activity.subjectType)
        if let post = activity.subject as? Post {
            self.assignRegionsFromContent(post.summary!)
        }
        else if let comment = activity.subject as? Comment {
            self.assignRegionsFromContent(comment.summary!)
        }
        self.subject = activity.subject
    }

    required init(author: User?, createdAt: NSDate, kind: Kind, notificationId: String, subjectType: SubjectType) {
        self.author = author
        self.attributedTitleStore = nil
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