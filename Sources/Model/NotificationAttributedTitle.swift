//
//  NotificationAttributedTitle.swift
//  Ello
//
//  Created by Colin Gray on 2/20/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct NotificationAttributedTitle {

    static private func attrs(addlAttrs : [String : AnyObject] = [:]) -> [String : AnyObject] {
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
        ]
        return attrs + addlAttrs
    }

    static private func style(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
    }

    static private func style(user: User?) -> NSAttributedString {
        if let user = user {
            return NSAttributedString(string: user.atName, attributes: attrs([
                ElloAttributedText.Link: "user",
                ElloAttributedText.Object: user,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        else {
            return style("Someone")
        }
    }

    static private func style(text: String, _ post: Post) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "post",
            ElloAttributedText.Object: post,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static private func style(text: String, _ comment: Comment) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "comment",
            ElloAttributedText.Object: comment,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func attributedTitle(kind: Activity.Kind, author: User?, subject: AnyObject?) -> NSAttributedString {
        switch kind {
            case .RepostNotification:
                if let post = subject as? Post {
                    return style(author)
                        .append(style(" reposted your "))
                        .append(style("post", post))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" reposted your post."))
                }
            case .NewFollowedUserPost:
                return style("You started following ")
                    .append(style(author))
                    .append(style("."))
            case .NewFollowerPost:
                return style(author)
                    .append(style(" started following you."))
            case .PostMentionNotification:
                if let post = subject as? Post {
                    return style(author)
                        .append(style(" mentioned you in a "))
                        .append(style("post", post))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" mentioned you in a post."))
                }
            case .CommentNotification:
                if let comment = subject as? Comment {
                    return style(author)
                        .append(style(" commented on your "))
                        .append(style("post", comment))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" commented on a post."))
                }
            case .CommentMentionNotification:
                if let comment = subject as? Comment {
                    return style(author)
                        .append(style(" mentioned you in a "))
                        .append(style("comment", comment))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" mentioned you in a comment."))
                }
            case .CommentOnOriginalPostNotification:
                if let comment = subject as? Comment,
                    let repost = comment.parentPost,
                    let repostAuthor = repost.author,
                    let source = repost.repostSource
                {
                    return style(author)
                        .append(style(" commented on "))
                        .append(style(repostAuthor))
                        .append(style("’s "))
                        .append(style("repost", repost))
                        .append(style(" of your "))
                        .append(style("post", source))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" commented on your post"))
                }
            case .CommentOnRepostNotification:
                if let comment = subject as? Comment {
                    return style(author)
                        .append(style(" commented on your "))
                        .append(style("repost", comment))
                        .append(style("."))
                }
                else {
                    return style(author)
                        .append(style(" commented on your repost"))
                }
            case .InvitationAcceptedPost:
                return style(author)
                    .append(style(" accepted your invitation."))
            case .LoveNotification:
                if let love = subject as? Love,
                    let post = love.post
                {
                    return style(author)
                        .append(style(" loved your "))
                        .append(style("post", post))
                        .append(style("."))
                }
                else {
                    return style(author).append(style(" loved your post."))
                }
            case .LoveOnRepostNotification:
                if let love = subject as? Love,
                    let post = love.post
                {
                    return style(author)
                        .append(style(" loved your "))
                        .append(style("repost", post))
                        .append(style("."))
                }
                else {
                    return style(author).append(style(" loved your repost."))
                }
            case .LoveOnOriginalPostNotification:
                if let love = subject as? Love,
                    let repost = love.post,
                    let repostAuthor = repost.author,
                    let source = repost.repostSource
                {
                    return style(author)
                        .append(style(" loved "))
                        .append(style(repostAuthor))
                        .append(style("’s "))
                        .append(style("repost", repost))
                        .append(style(" of your "))
                        .append(style("post", source))
                        .append(style("."))
                }
                else {
                    return style(author).append(style(" loved a repost of your post."))
                }
            case .WelcomeNotification:
                return style("Welcome to Ello!")
            default:
                return NSAttributedString(string: "")
        }
    }
}
