//
//  ImageAttachment.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let ImageAttachmentVersion = 1

final class ImageAttachment: NSObject, NSCoding {

    let version: Int = ImageAttachmentVersion

    let url: NSURL?
    let height: Int?
    let width: Int?
    let imageType: String?
    let size: Int?

// MARK: Initialization

    init(url: NSURL?,
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

    func encodeWithCoder(encoder: NSCoder) {
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

    required init(coder decoder: NSCoder) {
        self.url = decoder.decodeObjectForKey("url") as? NSURL

        if decoder.containsValueForKey("height") {
            self.height = Int(decoder.decodeIntForKey("height"))
        }
        else {
            self.height =  nil
        }

        if decoder.containsValueForKey("width") {
            self.width = Int(decoder.decodeIntForKey("width"))
        }
        else {
            self.width = nil
        }

        if decoder.containsValueForKey("size") {
            self.size = Int(decoder.decodeIntForKey("size"))
        }
        else {
            self.size = nil
        }

        self.imageType = decoder.decodeObjectForKey("imageType") as? String
    }
}
