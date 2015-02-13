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

struct Comment: Streamable {

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
}
