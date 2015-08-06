//
//  NewContentService.swift
//  Ello
//
//  Created by Sean on 7/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public typealias NewContentSuccessCompletion = (hasNewContent: Bool) -> Void

public struct NewContentNotifications {
    static let newNotifications = TypedNotification<NewContentService>(name: "NewNotificationsNotification")
    static let newStreamContent = TypedNotification<NewContentService>(name: "NewStreamContentNotification")
}

public class NewContentService {

    var timer: NSTimer?

    public init(){}

    public func startPolling() {
        timer?.invalidate()
        checkForNewContent()
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10.0), target: self, selector: Selector("checkForNewContent"), userInfo: nil, repeats: true)
    }

    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    public func checkForNewContent() {
        checkForNewNotifications()
        checkForNewStreamContent()
    }

    private func checkForNewNotifications() {
        let storedNotificationsDate = Defaults[StreamKind.Notifications(category: nil).lastViewedCreatedAtKey].date ?? NSDate(timeIntervalSince1970: 0)

        ElloProvider.elloRequest(
            ElloAPI.NotificationsNewContent(createdAt: storedNotificationsDate),
            success: { (_, responseConfig) in
                var hasNewNotifications = false
                if let statusCode = responseConfig.statusCode where statusCode == 204 {
                    hasNewNotifications = true
                    postNotification(NewContentNotifications.newNotifications, self)
                }
                println("notifications polled, hasNewNotifications = \(hasNewNotifications)")
            },
            failure: nil
        )
    }

    private func checkForNewStreamContent() {
        let storedFriendsDate = Defaults["friends-new-content-last-viewed-key"].date ?? NSDate(timeIntervalSince1970: 0)
        let storedNoiseDate = Defaults["noise-new-content-last-viewed-key"].date ?? NSDate(timeIntervalSince1970: 0)

        ElloProvider.elloRequest(
            ElloAPI.FriendNewContent(createdAt: storedFriendsDate),
            success: { (_, responseConfig) in
                var hasNewNotifications = false
                if let statusCode = responseConfig.statusCode where statusCode == 204 {
                    hasNewNotifications = true
                    postNotification(NewContentNotifications.newNotifications, self)
                }
                println("notifications polled, hasNewNotifications = \(hasNewNotifications)")
            },
            failure: nil
        )
    }



//    public func checkNotifications(#success: NewContentSuccessCompletion, failure: ElloFailureCompletion?)
//    {
//        let storedDate = Defaults[StreamKind.Notifications(category: nil).lastViewedCreatedAtKey].date ?? NSDate(timeIntervalSince1970: 0)
//
//        ElloProvider.elloRequest(
//            ElloAPI.NotificationsNewContent(createdAt: storedDate),
//            success: { (_, responseConfig) in
//                var hasNewContent = false
//                if let statusCode = responseConfig.statusCode where statusCode == 204 {
//                    hasNewContent = true
//                }
//                println("hasNewContent = \(hasNewContent) for date = \(storedDate)")
//                success(hasNewContent: hasNewContent)
//            },
//            failure: failure
//        )
//    }

    public func updateCreatedAt(jsonables: [JSONAble], streamKind: StreamKind) {
        let old = NSDate(timeIntervalSince1970: 0)
        let newestLoadedDate = jsonables.reduce(old) {
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

        let storedDate = Defaults[streamKind.lastViewedCreatedAtKey].date ?? old

        let mostRecent = newestLoadedDate > storedDate ? newestLoadedDate : storedDate

        Defaults[streamKind.lastViewedCreatedAtKey] = mostRecent
    }

}
