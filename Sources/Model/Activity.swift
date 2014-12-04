//
//  Activity.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON



class Activity: JSONAble {

    enum ActivityKinds: String {
        case OwnPost = "own_post"
        case FriendPost = "friend_post"
        case WelcomPost = "welcome_post"
        case Unknown = "Unknown"
    }

    enum ActivitySubjectType: String {
        case Post = "Post"
        case User = "User"
        case Unknown = "Unknown"
    }

    dynamic let createdAt: NSDate
    dynamic let activityId: Int
    let kind: ActivityKinds
    let subjectType: ActivitySubjectType
    dynamic let subject: AnyObject?


    init(kind: ActivityKinds, activityId: Int, createdAt: NSDate, subject:AnyObject?, subjectType: ActivitySubjectType) {
        self.kind = kind
        self.activityId = activityId
        self.createdAt = createdAt
        self.subject = subject
        self.subjectType = subjectType
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let kind = ActivityKinds(rawValue: json["kind"].stringValue) ?? ActivityKinds.Unknown
        let activityId = json["id"].intValue
        let subjectType = ActivitySubjectType(rawValue: json["subject_type"].stringValue) ?? ActivitySubjectType.Unknown

        var createdAt:NSDate = dateFromServerString(json["created_at"].stringValue) ?? NSDate()

        return Activity(kind: kind, activityId: activityId, createdAt: createdAt, subject: parseSubject(json, subjectType: subjectType), subjectType: subjectType)
    }

    class private func parseSubject(json:JSON, subjectType: ActivitySubjectType) -> AnyObject? {
        var subject:AnyObject?
        switch subjectType {
        case .User:
            if let userDict = json["subject"].object as? [String: AnyObject] {
                subject = User.fromJSON(userDict) as User
            }
        case .Post:
            if let postDict = json["subject"].object as? [String: AnyObject] {
                subject = Post.fromJSON(postDict) as Post
            }
        case .Unknown:
            subject = nil
        }
        return subject
    }

    override var description : String {
        return "\nActivity:\n\tsubjectType: \(self.subjectType.rawValue)\n\tsubject: \(subject)"
    }
}
