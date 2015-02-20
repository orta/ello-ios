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
    case Profile(user: User)
    case Notifications

    var name:String {
        switch self {
        case .Friend: return "Friends"
        case .Noise: return "Noise"
        case .Notifications: return "Notifications"
        case .PostDetail: return "Post Detail"
        case .Profile(let user): return "@\((user as User).username)"
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
        case .Profile(let user): return .UserStream(userId: (user as User).userId)
        }
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