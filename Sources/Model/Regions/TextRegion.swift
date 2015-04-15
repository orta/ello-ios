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

public final class TextRegion: JSONAble {

    public let version: Int = TextRegionVersion

    public let content:String

// MARK: Initialization

    public init(content: String) {
        self.content = content
        super.init()
    }

// MARK: NSCoding

    public override func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.content, forKey: "content")
        super.encodeWithCoder(encoder)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.content = decoder.decodeKey("content")
        super.init(coder: aDecoder)
    }
    
// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }
}
