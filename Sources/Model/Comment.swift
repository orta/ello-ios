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
    
    let commentId: String
    var createdAt: NSDate
    var content: [Block]
    var author: User?
    var kind = StreamableKind.Comment
    var parentPost: Post?
    var groupId:String {
        get {
            return parentPost?.postId ?? ""
        }
    }
    
    init(commentId: String, createdAt: NSDate, content: [Block], author: User?, parentPost: Post?) {
        self.commentId = commentId
        self.createdAt = createdAt
        self.content = content
        self.author = author
        self.parentPost = parentPost
    }
    
    override class func fromJSON(data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        
        var commentId = json["id"].stringValue
        var createdAt = json["created_at"].stringValue.toNSDate()!

        var comment = Comment(commentId: commentId, createdAt: createdAt, content: Block.blocks(json, assets:nil), author: nil, parentPost: nil)

        if let links = data["links"] as? [String: AnyObject] {
            parseLinks(links, model: comment)
            comment.author = comment.links["author"] as? User
            comment.parentPost = comment.links["parent_post"] as? Post
        }
        return comment
    }
}
