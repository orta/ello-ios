//
//  NotificationAttributedTitle.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct NotificationAttributedTitle {

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
                if let post = subject as? Post {
                    return self.profile(author)
                        .append(self.text(" reposted your "))
                        .append(self.post("post", post))
                        .append(self.text("."))
                }
                else {
                    return self.profile(author)
                    .append(self.text(" reposted your post."))
                }
            case .NewFollowedUserPost:
                return self.text("You started following ")
                    .append(self.profile(author))
                    .append(self.text("."))
            case .NewFollowerPost:
                return self.profile(author)
                    .append(self.text(" started following you."))
            case .PostMentionNotification:
                if let post = subject as? Post {
                    return self.profile(author)
                        .append(self.text(" mentioned you in a "))
                        .append(self.post("post", post))
                        .append(self.text("."))
                }
                else {
                    return self.profile(author)
                        .append(self.text(" mentioned you in a post."))
                }
            case .CommentMentionNotification:
                if let comment = subject as? Comment {
                    return self.profile(author)
                        .append(self.text(" mentioned you in a "))
                        .append(self.comment("comment", comment))
                        .append(self.text("."))
                }
                else {
                    return self.profile(author)
                        .append(self.text(" mentioned you in a comment."))
                }
            case .InvitationAcceptedPost:
                return self.profile(author)
                    .append(self.text(" accepted your invitation."))
            case .CommentNotification:
                if let comment = subject as? Comment {
                    return self.profile(author)
                        .append(self.text(" commented on your "))
                        .append(self.comment("post", comment))
                        .append(self.text("."))
                }
                else {
                    return self.profile(author)
                        .append(self.text(" commented on a post."))
                }
            case .WelcomeNotification:
                return self.text("Welcome to Ello!")
            default:
                return NSAttributedString(string: "")
        }
    }
}
