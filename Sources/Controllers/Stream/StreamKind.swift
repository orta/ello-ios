//
//  StreamKind.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public enum StreamKind {
    case Friend
    case Noise
    case Discover(type: DiscoverType, perPage: Int)
    case PostDetail(postParam: String)
    case Profile(perPage: Int)
    case UserStream(userParam: String)
    case Notifications
    case UserList(endpoint: ElloAPI, title: String)
    case Unknown

    public var name:String {
        switch self {
        case .Friend: return "Friends"
        case .Noise: return "Noise"
        case .Notifications: return "Notifications"
        case .Discover: return "Discover"
        case .PostDetail: return "Post Detail"
        case .Profile: return "Profile"
        case .UserStream: return "User Stream"
        case let .UserList(_, title): return title
        case .Unknown: return "unknown"
        }
    }

    public var columnCount:Int {
        switch self {
        case .Noise, .Discover: return 2
        default: return 1
        }
    }

    public var endpoint:ElloAPI {
        switch self {
        case .Friend: return .FriendStream
        case .Noise: return .NoiseStream
        case let .Discover(type, perPage): return ElloAPI.Discover(type: type, perPage: perPage)
        case .Notifications: return .NotificationsStream
        case let .PostDetail(postParam): return .PostDetail(postParam: postParam)
        case let .Profile(perPage): return .Profile(perPage: perPage)
        case let .UserStream(userParam): return .UserStream(userParam: userParam)
        case let .UserList(endpoint, title): return endpoint
        case .Unknown: return .NotificationsStream // doesn't really get used
        }
    }

    public var relationship: RelationshipPriority {
        switch self {
        case .Friend: return .Friend
        case .Noise: return .Noise
        default: return .Null
        }
    }

    public func filter(jsonables: [JSONAble]) -> [JSONAble] {
        switch self {
        case .UserList: return jsonables
        case .Discover:
            if let users = jsonables as? [User] {
                return users.reduce([]) { accum, user in
                    if let post = user.mostRecentPost {
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
                return activities.map { return Notification(activity: $0) }
            }
            else {
                return []
            }
        default:
            if let activities = jsonables as? [Activity] {
                return activities.reduce([]) { accum, activity in
                    if let post = activity.subject as? Post {
                        return accum + [post]
                    }
                    return accum
                }
            }
            else if let comments = jsonables as? [Comment] {
                return comments
            }
            else if let posts = jsonables as? [Post] {
                return posts
            }
        }
        return []
    }

    public var isGridLayout:Bool {
        return self.columnCount > 1
    }

   public var isDetail:Bool {
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

