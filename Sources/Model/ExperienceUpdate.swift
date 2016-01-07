//
//  ExperienceUpdate.swift
//  Ello
//
//  Created by Sean on 4/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public let CommentChangedNotification = TypedNotification<(Comment, ContentChange)>(name: "commentChangedNotification")
public let PostChangedNotification = TypedNotification<(Post, ContentChange)>(name: "postChangedNotification")
public let PostCommentsCountChangedNotification = TypedNotification<(Post, Int)>(name: "postCommentsCountChangedNotification")
public let LoveChangedNotification = TypedNotification<(Love, ContentChange)>(name: "loveChangedNotification")
public let RelationshipChangedNotification = TypedNotification<User>(name: "relationshipChangedNotification")
public let CurrentUserChangedNotification = TypedNotification<User>(name: "currentUserChangedNotification")
public let SettingChangedNotification = TypedNotification<User>(name: "settingChangedNotification")

public enum ContentChange {
    case Create
    case Read
    case Update
    case Loved
    case Replaced
    case Delete

    public static func updateCommentCount(comment: Comment, delta: Int) {
        var affectedPosts: [Post?]
        if comment.postId == comment.loadedFromPostId {
            affectedPosts = [comment.parentPost]
        }
        else {
            affectedPosts = [comment.parentPost, comment.loadedFromPost]
        }
        for post in affectedPosts {
            if let post = post, let count = post.commentsCount {
                if let storedPost = ElloLinkedStore.sharedInstance.getObject(post.id, inCollection: MappingType.PostsType.rawValue) as? Post {
                    storedPost.commentsCount = count + delta
                    ElloLinkedStore.sharedInstance.setObject(storedPost, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
                }
                postNotification(PostCommentsCountChangedNotification, value: (post, delta))
                postNotification(PostChangedNotification, value: (post, .Update))
            }
        }

    }

}
