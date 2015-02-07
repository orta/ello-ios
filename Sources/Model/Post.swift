//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post: JSONAble, Streamable {

    let postId: String
    var createdAt: NSDate
    let href: String
    let collapsed: Bool
    var content: [Block]
    var kind = StreamableKind.Post
    let token: String
    var author: User?
    let commentsCount: Int?
    let viewsCount: Int?
    let repostsCount: Int?
    var groupId:String {
        get { return postId }
    }

    init(postId: String, createdAt: NSDate, href: String, collapsed:Bool, content: [Block], token: String, commentsCount: Int?, viewsCount: Int?, repostsCount: Int?) {
        self.postId = postId
        self.createdAt = createdAt
        self.href = href
        self.collapsed = collapsed
        self.content = content
        self.token = token
        self.commentsCount = commentsCount
        self.viewsCount = viewsCount
        self.repostsCount = repostsCount
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

        let assets = json["assets"].object as? [String: AnyObject]

        let post = Post(postId: postId, createdAt: createdAt, href: href, collapsed: collapsed, content: Block.blocks(json, assets: assets), token: token, commentsCount: commentsCount, viewsCount: viewsCount, repostsCount: repostsCount)

        if let links = data["links"] as? [String: AnyObject] {
            parseLinks(links, model: post)
            post.author = post.links["author"] as? User
        }
        return post
    }
    override var description : String {
        return "Post:\n\tpostId:\(self.postId)"
    }
}
