//
//  Comment.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

class Comment: JSONAble, Streamable {

    var author: User?
    let commentId: String
    var content: [Regionable]?
    var createdAt: NSDate
    var groupId:String {
        get {
            return parentPost?.postId ?? ""
        }
    }
    var kind = StreamableKind.Comment
    var parentPost: Post?
    var summary: [Regionable]?

    init(author: User?,
        commentId: String,
        content: [Regionable]?,
        createdAt: NSDate,
        parentPost: Post?,
        summary: [Regionable]? )
    {
        self.author = author
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.parentPost = parentPost
        self.summary = summary
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        var commentId = json["id"].stringValue
        var createdAt = json["created_at"].stringValue.toNSDate()!

        var links = [String: AnyObject]()
        var parentPost:Post?
        var author: User?
        var content: [Regionable]?
        var summary: [Regionable]?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
            parentPost = links["parent_post"] as? Post
            //            var assets = links["assets"] as? [String:JSONAble]
            //            content = RegionParser.regions("content", json: json)
            //            summary = RegionParser.regions("summary", json: json)
        }

        return Comment(
            author: author,
            commentId: commentId,
            content: content,
            createdAt: createdAt,
            parentPost: parentPost,
            summary: summary
        )
    }
}
