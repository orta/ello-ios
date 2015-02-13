//
//  Asset.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

class Asset: JSONAble {
    let assetId: String
    let hdpi: ImageAttachment?
    let xxhdpi: ImageAttachment?

    init(assetId: String,
        hdpi: ImageAttachment?,
        xxhdpi: ImageAttachment?) {
            self.assetId = assetId
            self.hdpi = hdpi
            self.xxhdpi = xxhdpi
    }

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