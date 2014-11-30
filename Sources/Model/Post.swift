//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post: JSONAble {
    dynamic let body: String

    init(body: String) {
        self.body = body
    }

    override class func fromJSON(data: NSData) -> JSONAble {
        let json = JSON(data: data)
        let body = json["body"].stringValue
        return Post(body: body)
    }
}
