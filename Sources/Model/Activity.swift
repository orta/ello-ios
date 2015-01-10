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

    enum Kind: String {
        case OwnPost = "own_post"
        case FriendPost = "friend_post"
        case WelcomPost = "welcome_post"
        case Unknown = "Unknown"
    }

    enum SubjectType: String {
        case Post = "Post"
        case User = "User"
        case Unknown = "Unknown"
    }

    dynamic let createdAt: NSDate
    dynamic let activityId: Int
    let kind: Kind
    let subjectType: SubjectType
    dynamic let subject: AnyObject?


    init(kind: Kind, activityId: Int, createdAt: NSDate, subject:AnyObject?, subjectType: SubjectType) {
        self.kind = kind
        self.activityId = activityId
        self.createdAt = createdAt
        self.subject = subject
        self.subjectType = subjectType
    }

    override class func fromJSON(data:[String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
        let json = JSON(data)
        let kind = Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown
        let activityId = json["id"].intValue
        let subjectType = SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.Unknown
        var createdAt = json["created_at"].stringValue.toNSDate() ?? NSDate()

        return Activity(kind: kind, activityId: activityId, createdAt: createdAt, subject: parseSubject(json, subjectType: subjectType), subjectType: subjectType)
    }

    class private func parseSubject(json:JSON, subjectType: SubjectType) -> AnyObject? {
        var subject:AnyObject?
        switch subjectType {
        case .User:
            if let userDict = json["subject"].object as? [String: AnyObject] {
                subject = User.fromJSON(userDict, linked: nil) as User
            }
        case .Post:
            if let postDict = json["subject"].object as? [String: AnyObject] {
                subject = Post.fromJSON(postDict, linked: nil) as Post
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
