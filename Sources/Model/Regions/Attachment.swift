//
//  Attachment.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let AttachmentVersion = 1

public final class Attachment: JSONAble {

    // required
    public let url: NSURL
    // optional
    public var size: Int?
    public var width: Int?
    public var height: Int?
    public var type: String?
    public var image: UIImage?

// MARK: Initialization

    public init(url: NSURL) {
        self.url = url
        super.init(version: AttachmentVersion)
    }

// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // required
        self.url = decoder.decodeKey("url")
        // optional
        self.height = decoder.decodeOptionalKey("height")
        self.width = decoder.decodeOptionalKey("width")
        self.size = decoder.decodeOptionalKey("size")
        self.type = decoder.decodeOptionalKey("type")
        self.image = decoder.decodeOptionalKey("image")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // required
        coder.encodeObject(url, forKey: "url")
        // optional
        coder.encodeObject(height, forKey: "height")
        coder.encodeObject(width, forKey: "width")
        coder.encodeObject(size, forKey: "size")
        coder.encodeObject(type, forKey: "type")
        coder.encodeObject(image, forKey: "image")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        var url = json["url"].stringValue
        if url.hasPrefix("//") {
            url = ElloURI.httpProtocol + ":" + url
        }
        // create attachment
        var attachment = Attachment(url: NSURL(string: url)!)
        // optional
        attachment.size = json["metadata"]["size"].int
        attachment.width = json["metadata"]["width"].int
        attachment.height = json["metadata"]["height"].int
        attachment.type = json["metadata"]["type"].stringValue
        return attachment
    }
}
