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

public final class TextRegion: JSONAble, Regionable {
    public var isRepost: Bool = false
    
    public let content: String

// MARK: Initialization

    public init(content: String) {
        self.version = TextRegionVersion
        self.content = content
        super.init()
    }

// MARK: NSCoding

    public override func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(content, forKey: "content")
        encoder.encodeBool(isRepost, forKey: "isRepost")
        super.encodeWithCoder(encoder)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.content = decoder.decodeKey("content")
        self.isRepost = decoder.decodeKey("isRepost")
        super.init(coder: aDecoder)
    }
    
// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }

// MARK: Regionable 

    public var kind:String { return RegionKind.Text.rawValue }
    
    public func coding() -> NSCoding {
        return self
    }

    public func toJSON() -> [String: AnyObject] {
        return [
            "kind": self.kind,
            "data": self.content
        ]
    }
}
