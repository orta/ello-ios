//
//  Love.swift
//  Ello
//
//  Created by Sean on 5/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics
import SwiftyJSON
import Foundation

let LoveVersion: Int = 1

@objc(Love)
public final class Love: JSONAble {

    // active record
    public let id: String
    public let createdAt: NSDate
    public let updatedAt: NSDate
    // required
    public var deleted: Bool
    public let postId: String
    public let userId: String

    public var post: Post? {
        return ElloLinkedStore.sharedInstance.getObject(self.postId, inCollection: MappingType.PostsType.rawValue) as? Post
    }

    public var user: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.userId, inCollection: MappingType.UsersType.rawValue) as? User
    }

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        updatedAt: NSDate,
        deleted: Bool,
        postId: String,
        userId: String )
    {
        // active record
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        // required
        self.deleted = deleted
        self.postId = postId
        self.userId = userId
        super.init(version: LoveVersion)
    }


// MARK: NSCoding
    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        self.updatedAt = decoder.decodeKey("updatedAt")
        // required
        self.deleted = decoder.decodeKey("deleted")
        self.postId = decoder.decodeKey("postId")
        self.userId = decoder.decodeKey("userId")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(updatedAt, forKey: "updatedAt")
        // required
        coder.encodeObject(deleted, forKey: "deleted")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(userId, forKey: "userId")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.LoveFromJSON.rawValue)
        var createdAt: NSDate
        var updatedAt: NSDate
        if let date = json["created_at"].stringValue.toNSDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Love", json: json.rawString())
        }
        if let date = json["updated_at"].stringValue.toNSDate() {
            // good to go
            updatedAt = date
        }
        else {
            updatedAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Love Updated", json: json.rawString())
        }

        // create Love
        let love = Love(
            id: json["id"].stringValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: json["deleted"].boolValue,
            postId: json["post_id"].stringValue,
            userId: json["user_id"].stringValue
        )

        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(love, forKey: love.id, inCollection: MappingType.LovesType.rawValue)
        }

        return love
    }
}
