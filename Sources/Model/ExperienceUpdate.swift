//
//  ExperienceUpdate.swift
//  Ello
//
//  Created by Sean on 4/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public let ExperienceUpdatedNotification = TypedNotification<ExperienceUpdate>(name: "experienceUpdatedNotification")

public enum ExperienceUpdate {
    case CommentChanged(commentId: String, postId: String, change: ContentChange)
    case ContentActionRuleChanged(userId: String, action: ContentAction, allowed: Bool)
    case ContentVisibilityRuleChanged(userId: String, kind: VisibilityKind, visible: Bool)
    case PostChanged(id: String, change: ContentChange)
    case RelationshipChanged(relationship: Relationship, userId: String)
    case UserBlocked(id: String, blocked: Bool)
    case UserMuted(id: String, muted: Bool)
}


// Experience Update Helpers
public extension ExperienceUpdate {

    func affectsItems(items: [StreamCellItem]) -> Bool {
        return items.reduce(false) { $0.0 || self.affectsItem($0.1) }
    }

    func affectsItem(item: StreamCellItem) -> Bool {
        switch self {
        case .CommentChanged(let commentId, let postId, _):
            return comment(item)?.postId == postId ||
                comment(item)?.id == commentId
        case .ContentActionRuleChanged(let userId, _, _):
            return userAffected(userId, item: item)
        case .ContentVisibilityRuleChanged(let userId, _, _):
            return userAffected(userId, item: item)
        case .PostChanged(let id, _):
            return post(item)?.id == id
        case RelationshipChanged(_, let userId):
            return userAffected(userId, item: item)
        case .UserBlocked(let userId, _):
            return userAffected(userId, item: item)
        default: return false
        }
    }

    private func post(item: StreamCellItem) -> Post? {
        return item.jsonable as? Post
    }

    private func user(item: StreamCellItem) -> User? {
        return item.jsonable as? User
    }

    private func comment(item: StreamCellItem) -> Comment? {
        return item.jsonable as? Comment
    }

    private func userAffected(userId: String, item: StreamCellItem) -> Bool {
        return  post(item)?.author?.id == userId ||
                comment(item)?.parentPost?.author?.id == userId ||
                comment(item)?.author?.id == userId ||
                user(item)?.id == userId
    }
}

public enum ContentChange {
    case Create
    case Read
    case Update
    case Delete
}

public enum ContentAction {
    case Commenting
    case Sharing
    case Reposting
}

public enum VisibilityKind {
    case NSFW
    case EmbeddedMedia
}

public enum ExperienceUpdateResponse {
    case Reload
    case Remove
}

public protocol ExperienceUpdatable {
    func experienceUpdateResponse(update: ExperienceUpdate) -> ExperienceUpdateResponse?
}
