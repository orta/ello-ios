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
            return NSAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit.", attributes: attrs([
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
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" reposted your ")).append(TitleStyles.post("post", (subject! as Post).postId)).append(TitleStyles.text("."))
            case .NewFollowedUserPost:
                attributedTitleStore = TitleStyles.text("You started following ").append(TitleStyles.profile(author!.atName, author!.userId)).append(TitleStyles.text("."))
            case .NewFollowerPost:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" started following you."))
            case .PostMentionNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.post("post", (subject! as Post).postId)).append(TitleStyles.text("."))
            case .CommentMentionNotification:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" mentioned you in a ")).append(TitleStyles.comment("comment", (subject! as Comment).commentId)).append(TitleStyles.text("."))
            case .InvitationAcceptedPost:
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" accepted your invitation."))
            case .CommentNotification:
                println("subject: \(subject)")
                attributedTitleStore = TitleStyles.profile(author!.atName, author!.userId).append(TitleStyles.text(" commented on your ")).append(TitleStyles.post("post", (subject! as Comment).commentId)).append(TitleStyles.text("."))
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