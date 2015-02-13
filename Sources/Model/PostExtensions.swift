//
//  PostExtensions.swift
//  Ello
//
//  Created by Sean on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Post: JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let postId = json["id"].stringValue
        var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
        let href = json["href"].stringValue
        let collapsed = json["collapsed"].boolValue
        let token = json["token"].stringValue
        let viewsCount = json["views_count"].int
        let commentsCount = json["comments_count"].int
        let repostsCount = json["reposts_count"].int

        let assets = json["assets"].object as? [String: AnyObject]


        var links = [String: Any]()
        var author: User?
        var content: [Regionable]?
        var summary: [Regionable]?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
            var assets = links["assets"] as? [String:JSONAble]
            content = RegionParser.regions("content", json: json, assets: assets)
            summary = RegionParser.regions("summary", json: json, assets: assets)
        }

        return Post(
            assets: nil,
            author: author,
            collapsed: collapsed,
            commentsCount: commentsCount,
            content: content,
            createdAt: createdAt,
            href: href, kind: StreamableKind.Post,
            postId: postId,
            repostsCount: repostsCount,
            summary: summary,
            token: token,
            viewsCount: viewsCount
        )
    }
}
