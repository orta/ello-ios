//
//  NotificationAttributedTitle.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct Attributed {
    static let Link : NSString = "ElloLinkAttributedString"
    static let Object : NSString = "ElloObjectAttributedString"
}


struct NotificationAttributedTitle {

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

    static func profile(user : User?) -> NSAttributedString {
        if let user = user {
            return NSAttributedString(string: user.atName, attributes: attrs([
                Attributed.Link : "user",
                Attributed.Object : user,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        else {
            return text("Someone")
        }
    }

    static func post(text : String, _ post : Post) -> NSAttributedString {
        var attrs = self.attrs([
            Attributed.Link : "post",
            Attributed.Object : post,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func comment(text : String, _ comment : Comment) -> NSAttributedString {
        var attrs = self.attrs([
            Attributed.Link : "comment",
            Attributed.Object : comment,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func attributedTitle(kind: Activity.Kind, author: User?, subject: AnyObject?) -> NSAttributedString {
        switch kind {
            case .RepostNotification:
                return self.profile(author)
                    .append(self.text(" reposted your "))
                    .append(self.post("post", subject! as Post))
                    .append(self.text("."))
            case .NewFollowedUserPost:
                return self.text("You started following ")
                    .append(self.profile(author))
                    .append(self.text("."))
            case .NewFollowerPost:
                return self.profile(author)
                    .append(self.text(" started following you."))
            case .PostMentionNotification:
                return self.profile(author)
                    .append(self.text(" mentioned you in a "))
                    .append(self.post("post", subject! as Post))
                    .append(self.text("."))
            case .CommentMentionNotification:
                return self.profile(author)
                    .append(self.text(" mentioned you in a "))
                    .append(self.comment("comment", subject! as Comment))
                    .append(self.text("."))
            case .InvitationAcceptedPost:
                return self.profile(author)
                    .append(self.text(" accepted your invitation."))
            case .CommentNotification:
                return self.profile(author)
                    .append(self.text(" commented on your "))
                    .append(self.comment("post", subject! as Comment))
                    .append(self.text("."))
            case .WelcomeNotification:
                return self.text("Welcome to Ello!")
            default:
                return NSAttributedString(string: "")
        }
    }

}