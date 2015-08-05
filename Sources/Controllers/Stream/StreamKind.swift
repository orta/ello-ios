//
//  StreamKind.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public enum StreamKind {
    case Discover(type: DiscoverType, perPage: Int)
    case Friend
    case Noise
    case Notifications(category: String?)
    case PostDetail(postParam: String)
    case Profile(perPage: Int)
    case SimpleStream(endpoint: ElloAPI, title: String)
    case Unknown
    case UserStream(userParam: String)

    public var name:String {
        switch self {
        case .Discover: return "Discover"
        case .Friend: return "Friends"
        case .Noise: return "Noise"
        case .Notifications: return "Notifications"
        case .PostDetail: return "Post Detail"
        case .Profile: return "Profile"
        case let .SimpleStream(_, title): return title
        case .Unknown: return "unknown"
        case .UserStream: return "User Stream"
        }
    }

    public var lastViewedCreatedAtKey: String {
        return self.name + "_createdAt"
    }

    public var columnCount:Int {
        switch self {
        case .Noise, .Discover: return 2
        default: return 1
        }
    }

    public var tappingTextOpensDetail: Bool {
        switch self {
            case .PostDetail, .Friend, .Profile, .UserStream:
                return false
            default:
                return true
        }
    }

    public var endpoint: ElloAPI {
        switch self {
        case let .Discover(type, perPage): return ElloAPI.Discover(type: type, perPage: perPage)
        case .Friend: return .FriendStream
        case .Noise: return .NoiseStream
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
        case .Friend: return .Friend
        case .Noise: return .Noise
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

    public var isGridLayout: Bool {
        return self.columnCount > 1
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

    static let streamValues = [Friend, Noise]
}

