//
//  StreamKind.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

enum StreamKind {
    case Friend
    case Noise
    case PostDetail(post: Post)
    case Profile(userParam: String)
    case Notifications
    case UserList(endpoint: ElloAPI, title: String)

    var name:String {
        switch self {
        case .Friend: return "Friends"
        case .Noise: return "Noise"
        case .Notifications: return "Notifications"
        case .PostDetail: return "Post Detail"
        case .Profile: return "Profile"
        case .UserList(let title): return "\(title)"
        }
    }

    var columnCount:Int {
        switch self {
        case .Noise: return 2
        default: return 1
        }
    }

    var endpoint:ElloAPI {
        switch self {
        case .Friend: return .FriendStream
        case .Noise: return .NoiseStream
        case .Notifications: return .NotificationsStream
        case .PostDetail: return .NoiseStream // never use
        case .Profile(let userParam): return .UserStream(userParam: userParam)
        case .UserList(let endpoint, let title): return endpoint
        }
    }

    var relationship: Relationship {
        switch self {
        case .Friend: return .Friend
        case .Noise: return .Noise
        default: return .Null
        }
    }

    func filter(jsonables: [JSONAble]) -> [JSONAble] {
        switch self {
        case .UserList(let endpoint, let title): return jsonables
        case .Notifications:
            if let activities = jsonables as? [Activity] {
                let notifications: [Notification] = activities.map { return Notification(activity: $0) }
                return notifications
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

    var isGridLayout:Bool {
        return self.columnCount > 1
    }

    var isDetail:Bool {
        switch self {
        case .PostDetail: return true
        default: return false
        }
    }

    static let streamValues = [Friend, Noise]
}