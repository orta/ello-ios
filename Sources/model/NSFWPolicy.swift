//
//  NSFWPolicy.swift
//  Ello
//
//  Created by Sean on 5/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

public struct NSFWPolicy {
    public let alwaysViewNSFW: [String]
    public let loggedInViewsNSFW: [String]
    public let currentUserViewsOwnNSFW: Bool

    public init(
        alwaysViewNSFW: [String],
        loggedInViewsNSFW: [String],
        currentUserViewsOwnNSFW: Bool) {
        self.alwaysViewNSFW = alwaysViewNSFW
        self.loggedInViewsNSFW = loggedInViewsNSFW
        self.currentUserViewsOwnNSFW = currentUserViewsOwnNSFW
    }

    public func includeNSFW(
        endpoint: ElloAPI,
        currentUser: User?) -> Bool {

        switch endpoint {
        case let .InfiniteScroll(_, elloApi):
            includeNSFW(elloApi(), currentUser: currentUser)
        case let .UserStream(userParam):
            if isMe(userParam, currentUser: currentUser) {
                return true
            }
        case let .Loves(userId):
            if isMe(userId, currentUser: currentUser) {
                return true
            }
        default: break
        }

        if self.alwaysViewNSFW.contains(endpoint.description) {
            return true
        } else if self.loggedInViewsNSFW.contains(endpoint.description) {
            if let currentUser = currentUser {
                return currentUser.viewsAdultContent
            }
        }

        return false
    }

    private func isMe(userParam: String, currentUser: User?) -> Bool {
        var matchFound = false
        if let currentUser = currentUser where
            "~\(currentUser.username)" == userParam {
            matchFound = true
        }

        if currentUser?.id == userParam {
            matchFound = true
        }

        return matchFound && self.currentUserViewsOwnNSFW
    }
}
