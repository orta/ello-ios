//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Post: Streamable {
    var assets: [String:Asset]?
    var author: User?
    let collapsed: Bool
    let commentsCount: Int?
    var content: [Regionable]?
    var createdAt: NSDate
    var groupId:String {
        get { return postId }
    }
    let href: String
    var kind = StreamableKind.Post
    let postId: String
    let repostsCount: Int?
    var summary: [Regionable]?
    let token: String
    let viewsCount: Int?
}
