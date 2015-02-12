//
//  ActivityExtensions.swift
//  Ello
//
//  Created by Sean on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Activity: JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let sub = json["subject"]
        let kind = Kind(rawValue: json["kind"].stringValue) ?? Kind.Unknown
        let activityId = json["created_at"].stringValue
        let subjectType = SubjectType(rawValue: json["subject_type"].stringValue) ?? SubjectType.Unknown
        var createdAt = json["created_at"].stringValue.toNSDate() ?? NSDate()

        var links = [String: Any]()
        var subject:Any?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            subject = links["subject"]
        }

        return Activity(
            activityId: activityId,
            kind: kind,
            subjectType: subjectType,
            subject: subject,
            createdAt: createdAt
        )
    }

}
