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


public struct NewContentService {

    public init(){}

    public func checkNotifications(#success: NewContentSuccessCompletion, failure: ElloFailureCompletion?)
    {
        let storedDate = Defaults[StreamKind.Notifications(category: nil).lastViewedCreatedAtKey].date ?? NSDate(timeIntervalSince1970: 0)

        ElloProvider.elloRequest(
            ElloAPI.NotificationsNewContent(createdAt: storedDate),
            success: { (_, responseConfig) in
                var hasNewContent = false
                if let statusCode = responseConfig.statusCode where statusCode == 204 {
                    hasNewContent = true
                }
                println("hasNewContent = \(hasNewContent) for date = \(storedDate)")
                success(hasNewContent: hasNewContent)
            },
            failure: failure
        )
    }

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
