//
//  Notification.swift
//  Ello
//
//  Created by Colin Gray on 2/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON


class Notification: JSONAble, Streamable {
    let notificationId: String

    // Streamable
    var author:User?
    var createdAt:NSDate
    var kind:StreamableKind
    var content:[Block]?
    var groupId:String { return notificationId }

    init(notificationId: String, createdAt: NSDate, content: [Block]?) {
        self.notificationId = notificationId
        self.createdAt = createdAt
        self.kind = .Notification
        self.content = content
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let notificationId = json["id"].stringValue
        var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
        let notification = Notification(notificationId: notificationId, createdAt: createdAt, content: nil)

        if let links = data["links"] as? [String: AnyObject] {
            parseLinks(links, model: notification)
            notification.author = notification.links["author"] as? User
        }

        notification.content = Block.blocks(json, assets: notification.links["assets"] as? [String: AnyObject])

        return notification
    }
}
