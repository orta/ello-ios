//
//  StreamKind.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public enum StreamKind {
    case Discover(type: DiscoverType, perPage: Int)
    case Following
    case Starred
    case Notifications(category: String?)
    case PostDetail(postParam: String)
    case Profile(perPage: Int)
    case SimpleStream(endpoint: ElloAPI, title: String)
    case Unknown
    case UserStream(userParam: String)

    public var name: String {
        switch self {
        case .Discover: return "Discover"
        case .Following: return "Following"
        case .Starred: return "Starred"
        case .Notifications: return "Notifications"
        case .PostDetail: return "Post Detail"
        case .Profile: return "Profile"
        case let .SimpleStream(_, title): return title
        case .Unknown: return "unknown"
        case .UserStream: return "User Stream"
        }
    }

    public var cacheKey: String {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .SearchForPosts:
                return "SearchForPosts"
            default:
                return self.name
            }
        default:
            return self.name
        }
    }

    public var lastViewedCreatedAtKey: String {
        return self.name + "_createdAt"
    }

    public var columnCount: Int {
        if self.isGridView {
            return 2
        }
        else {
            return 1
        }
    }

    public var tappingTextOpensDetail: Bool {
        switch self {
            case .PostDetail, .Following, .Profile, .UserStream:
                return false
            default:
                return true
        }
    }

    public var endpoint: ElloAPI {
        switch self {
        case let .Discover(type, perPage): return ElloAPI.Discover(type: type, perPage: perPage)
        case .Following: return .FriendStream
        case .Starred: return .NoiseStream
        case let .Notifications(category): return .NotificationsStream(category: category)
        case let .PostDetail(postParam): return .PostDetail(postParam: postParam)
        case let .Profile(perPage): return .Profile(perPage: perPage)
        case let .SimpleStream(endpoint, _): return endpoint
        case .Unknown: return .NotificationsStream(category: nil) // doesn't really get used
        case let .UserStream(userParam): return .UserStream(userParam: userParam)
        }
    }

    public var relationship: RelationshipPriority {
        switch self {
        case .Following: return .Following
        case .Starred: return .Starred
        default: return .Null
        }
    }

    public func filter(jsonables: [JSONAble], viewsAdultContent: Bool) -> [JSONAble] {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .Loves:
                if let loves = jsonables as? [Love] {
                    return loves.reduce([]) { accum, love in
                        if let post = love.post where !post.isAdultContent {
                            return accum + [post]
                        }
                        return accum
                    }
                }
                else {
                    return []
                }
            default:
                if let posts = jsonables as? [Post] {
                    return posts.reduce([]) { accum, post in
                        if !post.isAdultContent {
                            return accum + [post]
                        }
                        return accum
                    }

                }
                else if let users = jsonables as? [User] {
                    return users.reduce([]) { accum, user in
                        if !user.postsAdultContent {
                            return accum + [user]
                        }
                        return accum
                    }
                }
                else {
                    return jsonables
                }
            }
        case .Discover:
            if let users = jsonables as? [User] {
                return users.reduce([]) { accum, user in
                    if let post = user.mostRecentPost where !post.isAdultContent {
                        return accum + [post]
                    }
                    return accum
                }
            }
            else {
                return []
            }
        case .Notifications:
            if let activities = jsonables as? [Activity] {
                let notifications: [Notification] = activities.map { return Notification(activity: $0) }
                return notifications.filter { return $0.isValidKind }
            }
            else {
                return []
            }
        default:
            if let activities = jsonables as? [Activity] {
                return activities.reduce([]) { accum, activity in
                    if let post = activity.subject as? Post where !post.isAdultContent || viewsAdultContent {
                        return accum + [post]
                    }
                    return accum
                }
            }
            else if let comments = jsonables as? [Comment] {
                return comments
            }
            else if let posts = jsonables as? [Post] {
                return posts.reduce([]) { accum, post in
                    if !post.isAdultContent || viewsAdultContent {
                        return accum + [post]
                    }
                    return accum
                }

            }
        }
        return []
    }

    public var gridPreferenceSetOffset: CGPoint {
        switch self {
        case .Discover: return CGPoint(x: 0, y: -80)
        default: return CGPoint(x: 0, y: -20)
        }
    }

    public var hasDiscoverStreamPicker: Bool {
        switch self {
        case .Discover: return true
        default: return false
        }
    }

    public var avatarHeight: CGFloat {
        return self.isGridView ? 30.0 : 60.0
    }

    public func contentForPost(post: Post) -> [Regionable]? {
        return self.isGridView ? post.summary : post.content
    }

    public var gridViewPreferenceSet: Bool {
        let prefSet = Defaults["\(self.cacheKey)GridViewPreferenceSet"].bool
        return prefSet != nil
    }

    public func setIsGridView(isGridView: Bool) {
        Defaults["\(cacheKey)GridViewPreferenceSet"] = true
        Defaults["\(cacheKey)IsGridView"] = isGridView
    }

    public var isGridView: Bool {
        return Defaults["\(cacheKey)IsGridView"].bool ?? false
    }

    public func clientSidePostInsertIndexPath(currentUserId: String?) -> NSIndexPath? {
        switch self {
        case .Following, .Profile:
            return NSIndexPath(forItem: 1, inSection: 0)
        case let .UserStream(userParam):
            if currentUserId == userParam {
                return NSIndexPath(forItem: 1, inSection: 0)
            }
        default: return nil
        }
        return nil
    }

    public var clientSideLoveInsertIndexPath: NSIndexPath? {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .Loves: return NSIndexPath(forItem: 1, inSection: 0)
            default: return nil
            }
        default: return nil
        }
    }

    public var hasGridViewToggle: Bool {
        switch self {
        case .Following, .Starred, .Discover: return true
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .SearchForPosts, .Loves:
                return true
            default:
                return false
            }
        default: return false
        }
    }

    public var showStarButton: Bool {
        switch self {
        case let .SimpleStream(endpoint, _):
            switch endpoint {
            case .AwesomePeopleStream, .CommunitiesStream, .FoundersStream:
                return false
            default:
                break
            }
        default:
            break
        }
        return true
    }

    public var isDetail: Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }

    public var supportsLargeImages: Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }
}

