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

class Comment: JSONAble {
    
    let commentId: Int
    let createdAt: NSDate
    let summary: [String]
    let author: User?
    
    init(commentId: Int, createdAt: NSDate, summary: [String], author: User?) {
        self.commentId = commentId
        self.createdAt = createdAt
        self.summary = summary
        self.author = author
    }
    
    override class func fromJSON(data: [String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
     
        var mutableData = JSONAble.linkItems(data, linked: linked)
       
        let json = JSON(mutableData)
        
        var commentId = json["id"].stringValue.toInt()
        var createdAt = json["created_at"].stringValue.toNSDate()!
        let summary = json["summary"].object as [String]
        
        var author:User?
        if let authorDict = json["author"].object as? [String: AnyObject] {
            author = User.fromJSON(authorDict, linked: nil) as? User
        }

        return Comment(commentId: commentId!, createdAt: createdAt, summary: summary, author: author)
    }
}
