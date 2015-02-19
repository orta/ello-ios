//
//  Notification.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class Notification : JSONAble, Authorable {
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
            case .RepostNotification:         return NSAttributedString(string: "\(author!.atName) reposted your post.")
            case .NewFollowedUserPost:        return NSAttributedString(string: "You started following \(author!.atName).")
            case .NewFollowerPost:            return NSAttributedString(string: "\(author!.atName) started following you.")
            case .PostMentionNotification:    return NSAttributedString(string: "\(author!.atName) mentioned you in a post.")
            case .CommentMentionNotification: return NSAttributedString(string: "\(author!.atName) mentioned you in a comment.")
            case .InvitationAcceptedPost:     return NSAttributedString(string: "\(author!.atName) accepted your invitation.")
            case .CommentNotification:        return NSAttributedString(string: "\(author!.atName) commented on your post.")
            case .WelcomeNotification:        return NSAttributedString(string: "Welcome to Ello!")
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