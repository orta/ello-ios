//
//  NewContentService.swift
//  Ello
//
//  Created by Sean on 7/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public struct NewContentNotifications {
    public static let newNotifications = TypedNotification<Void?>(name: "NewNotificationsNotification")
    public static let newStreamContent = TypedNotification<Void?>(name: "NewStreamContentNotification")
    public static let reloadStreamContent = TypedNotification<Void?>(name: "ReloadStreamContentNotification")
    public static let reloadNotifications = TypedNotification<Void?>(name: "ReloadNotificationsNotification")
}

public class NewContentService {

    var timer: NSTimer?

    public init(){}
}

public extension NewContentService {

    public func startPolling() {
        checkForNewNotifications()
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10), target: self, selector: #selector(NewContentService.checkForNewContent), userInfo: nil, repeats: false)
    }

    public func restartPolling() {
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10), target: self, selector: #selector(NewContentService.checkForNewContent), userInfo: nil, repeats: false)
    }

    public func stopPolling() {
        timer?.invalidate()
    }

    @objc
    public func checkForNewContent() {
        stopPolling()
        let restart = after(2, block: restartPolling)
        checkForNewNotifications(restart)
        checkForNewStreamContent(restart)
    }

    public func updateCreatedAt(jsonables: [JSONAble], streamKind: StreamKind) {
        let old = NSDate(timeIntervalSince1970: 0)
        let new = newestDate(jsonables)
        let storedDate = GroupDefaults[streamKind.lastViewedCreatedAtKey].date ?? old
        let mostRecent = new > storedDate ? new : storedDate
        GroupDefaults[streamKind.lastViewedCreatedAtKey] = mostRecent
    }
}


private extension NewContentService {

    func newestDate(jsonables: [JSONAble]) -> NSDate {
        let old = NSDate(timeIntervalSince1970: 0)
        return jsonables.reduce(old) {
            (date, jsonable) -> NSDate in
            if let post = jsonable as? Post {
                return post.createdAt > date ? post.createdAt : date
            }
            else if let notification = jsonable as? Notification {
                return notification.createdAt > date ? notification.createdAt : date
            }
            else if let activity = jsonable as? Activity {
                return activity.createdAt > date ? activity.createdAt : date
            }
            return date
        }
    }

    func checkForNewNotifications(done: BasicBlock = {}) {
        let storedNotificationsDate = GroupDefaults[StreamKind.Notifications(category: nil).lastViewedCreatedAtKey].date ?? NSDate(timeIntervalSince1970: 0)

        ElloProvider.shared.elloRequest(
            ElloAPI.NotificationsNewContent(createdAt: storedNotificationsDate),
            success: { (_, responseConfig) in
                if let statusCode = responseConfig.statusCode where statusCode == 204 {
                    postNotification(NewContentNotifications.newNotifications, value: nil)
                }

                done()
            },
            failure: { _ in done() })
    }

    func checkForNewStreamContent(done: BasicBlock = {}) {
        let storedFriendsDate = GroupDefaults[StreamKind.Following.lastViewedCreatedAtKey].date ?? NSDate(timeIntervalSince1970: 0)

        ElloProvider.shared.elloRequest(
            ElloAPI.FriendNewContent(createdAt: storedFriendsDate),
            success: { (_, responseConfig) in
                if let lastModified = responseConfig.lastModified {
                    GroupDefaults[StreamKind.Following.lastViewedCreatedAtKey] = lastModified.toNSDate(HTTPDateFormatter)
                }

                if let statusCode = responseConfig.statusCode where statusCode == 204 {
                    postNotification(NewContentNotifications.newStreamContent, value: nil)
                }

                done()
            },
            failure: { _ in done() })
    }
}
