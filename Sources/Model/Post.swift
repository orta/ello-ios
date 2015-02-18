//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON


@objc protocol Authorable {
    var createdAt : NSDate { get }
    var groupId: String { get }
    var author : User? { get }
}


class Post: JSONAble, Authorable {

    var assets: [String:Asset]?
    var author: User?
    let collapsed: Bool
    let commentsCount: Int?
    var content: [Regionable]?
    var createdAt: NSDate
    var groupId:String { return postId }
    let href: String
    let postId: String
    let repostsCount: Int?
    var summary: [Regionable]?
    let token: String
    let viewsCount: Int?

    init(assets: [String:Asset]?,
        author: User?,
        collapsed: Bool,
        commentsCount: Int?,
        content: [Regionable]?,
        createdAt: NSDate,
        href: String,
        postId: String,
        repostsCount: Int?,
        summary: [Regionable]?,
        token: String,
        viewsCount: Int?)
    {
        self.assets = assets
        self.author = author
        self.collapsed = collapsed
        self.commentsCount = commentsCount
        self.content = content
        self.createdAt = createdAt
        self.href = href
        self.postId = postId
        self.repostsCount = repostsCount
        self.summary = summary
        self.token = token
        self.viewsCount = viewsCount
    }

     override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let postId = json["id"].stringValue
        var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
        let href = json["href"].stringValue
        let collapsed = json["collapsed"].boolValue
        let token = json["token"].stringValue
        let viewsCount = json["views_count"].int
        let commentsCount = json["comments_count"].int
        let repostsCount = json["reposts_count"].int
        var links = [String: AnyObject]()
        var author: User?
        var content: [Regionable]?
        var summary: [Regionable]?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
//            var assets = links["assets"] as? [String:JSONAble]
            content = RegionParser.regions("content", json: json)
            summary = RegionParser.regions("summary", json: json)
        }

        return Post(
            assets: nil,
            author: author,
            collapsed: collapsed,
            commentsCount: commentsCount,
            content: content,
            createdAt: createdAt,
            href: href,
            postId: postId,
            repostsCount: repostsCount,
            summary: summary,
            token: token,
            viewsCount: viewsCount
        )
    }

    override var description : String {
        return "Post:\n\tpostId:\(self.postId)"
    }
}
