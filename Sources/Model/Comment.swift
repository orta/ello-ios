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
    let parentPost: Post?
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
        let linkedData = JSONAble.linkItems(data)
        let json = JSON(linkedData)
        
        var commentId = json["id"].stringValue
        var createdAt = json["created_at"].stringValue.toNSDate()!
       
        var author:User?
        if let authorDict = json["author"].object as? [String: AnyObject] {
            author = User.fromJSON(authorDict) as? User
        }
        
        var parentPost:Post?
        if let parentPostDict = json["parent_post"].object as? [String: AnyObject] {
            parentPost = Post.fromJSON(parentPostDict) as? Post
        }

        return Comment(commentId: commentId, createdAt: createdAt, content: Block.blocks(json, assets:nil), author: author, parentPost: parentPost)
    }
}
