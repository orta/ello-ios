//
//  TextRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let TextRegionVersion = 1

final class TextRegion: JSONAble, NSCoding {

    let version: Int = TextRegionVersion

    let content:String

// MARK: Initialization

    init(content: String) {
        self.content = content
    }

// MARK: NSCoding

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.content, forKey: "content")
    }

    required init(coder decoder: NSCoder) {
        self.content = decoder.decodeObjectForKey("content") as String
    }
    
// MARK: JSONAble

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }

}