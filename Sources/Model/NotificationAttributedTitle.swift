//
//  NotificationAttributedTitle.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

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
                ElloAttributedText.Link : "user",
                ElloAttributedText.Object : user,
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        else {
            return text("Someone")
        }
    }

    static func post(text : String, _ post : Post) -> NSAttributedString {
        var attrs = self.attrs([
            ElloAttributedText.Link : "post",
            ElloAttributedText.Object : post,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func comment(text : String, _ comment : Comment) -> NSAttributedString {
        var attrs = self.attrs([
            ElloAttributedText.Link : "comment",
            ElloAttributedText.Object : comment,
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