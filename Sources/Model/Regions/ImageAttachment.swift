//
//  ImageAttachment.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let ImageAttachmentVersion = 1

public final class ImageAttachment: NSObject, NSCoding {

    public let version: Int = ImageAttachmentVersion

    public let url: NSURL?
    public let height: Int?
    public let width: Int?
    public let imageType: String?
    public let size: Int?

// MARK: Initialization

    public init(url: NSURL?,
        height: Int?,
        width: Int?,
        imageType: String?,
        size: Int?) {
            self.url = url
            self.height = height
            self.width = width
            self.imageType = imageType
            self.size = size
    }

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        if let url = self.url {
            encoder.encodeObject(url, forKey: "url")
        }

        if let height = self.height {
            encoder.encodeInt64(Int64(height), forKey: "height")
        }

        if let width = self.width {
            encoder.encodeInt64(Int64(width), forKey: "width")
        }

        if let imageType = self.imageType {
            encoder.encodeObject(imageType, forKey: "imageType")
        }

        if let size = self.size {
            encoder.encodeInt64(Int64(size), forKey: "size")
        }
    }

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.url = decoder.decodeOptionalKey("url")
        self.height = decoder.decodeOptionalKey("height")
        self.width = decoder.decodeOptionalKey("width")
        self.size = decoder.decodeOptionalKey("size")
        self.imageType = decoder.decodeOptionalKey("imageType")
    }
}
