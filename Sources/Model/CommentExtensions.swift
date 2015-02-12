//
//  CommentExtensions.swift
//  Ello
//
//  Created by Sean on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Comment: JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        var commentId = json["id"].stringValue
        var createdAt = json["created_at"].stringValue.toNSDate()!

        var links = [String: Any]()
        var parentPost:Post?
        var author: User?
        var content: [Regionable]?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
            parentPost = links["parent_post"] as? Post
            var assets = links["assets"] as? [String:JSONAble]
            content = RegionParser.regions(json, assets:assets)
        }
        
        return Comment(
            author: author,
            commentId: commentId,
            content: content,
            createdAt: createdAt,
            kind: StreamableKind.Comment,
            parentPost: parentPost
        )
    }

}
