//
//  TextRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

class TextRegion: JSONAble {
    let content:String

    init(content: String) {
        self.content = content
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }
}