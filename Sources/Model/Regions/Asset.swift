//
//  Asset.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let AssetVersion = 1

final class Asset: JSONAble {

    let version: Int = AssetVersion

    let assetId: String
    let hdpi: ImageAttachment?
    let xxhdpi: ImageAttachment?

// MARK: Initialization
    
    init(assetId: String,
        hdpi: ImageAttachment?,
        xxhdpi: ImageAttachment?) {
            self.assetId = assetId
            self.hdpi = hdpi
            self.xxhdpi = xxhdpi
    }

// MARK: NSCoding

    required init(coder decoder: NSCoder) {
        self.assetId = decoder.decodeObjectForKey("assetId") as String
        self.hdpi = decoder.decodeObjectForKey("hdpi") as? ImageAttachment
        self.xxhdpi = decoder.decodeObjectForKey("xxhdpi") as? ImageAttachment
    }

    func encodeWithCoder(encoder: NSCoder) {

        encoder.encodeObject(self.assetId, forKey: "assetId")

        if let hdpi = self.hdpi {
            encoder.encodeObject(hdpi, forKey: "hdpi")
        }

        if let xxhdpi = self.xxhdpi {
            encoder.encodeObject(xxhdpi, forKey: "xxhdpi")
        }
    }
    
// MARK: JSONAble

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let assetId = data["id"] as? String ?? ""
        let attachment = data["attachment"] as? [String:AnyObject]
        let hdpi = Asset.createImageAttachment("hdpi", attachment: attachment)
        let xxhdpi = Asset.createImageAttachment("xxhdpi", attachment: attachment)

        return Asset(
            assetId: assetId,
            hdpi: hdpi,
            xxhdpi: xxhdpi
        )
    }

// MARK: Private

    private class func createImageAttachment(sizeKey:String, attachment:[String: AnyObject]?) -> ImageAttachment? {

        if let attachment = attachment {
            if let size = attachment[sizeKey] as? [String:AnyObject] {
                return ImageAttachment(
                    url: NSURL(string: size["url"] as String),
                    height: size["metadata"]?["height"] as? Int,
                    width: size["metadata"]?["width"] as? Int,
                    imageType: size["metadata"]?["type"] as? String,
                    size: size["metadata"]?["size"] as? Int
                )
            }
        }
        
        return nil
    }
}