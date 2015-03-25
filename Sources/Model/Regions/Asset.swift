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
    var isGif: Bool {
        return self.optimized?.imageType == "image/gif"
    }

    let optimized: ImageAttachment?
    let smallScreen: ImageAttachment?
    let ldpi: ImageAttachment?
    let mdpi: ImageAttachment?
    let hdpi: ImageAttachment?
    let xhdpi: ImageAttachment?
    let xxhdpi: ImageAttachment?
    let xxxhdpi: ImageAttachment?

// MARK: Initialization
    
    init(assetId: String,
        optimized: ImageAttachment?,
        smallScreen: ImageAttachment?,
        ldpi: ImageAttachment?,
        mdpi: ImageAttachment?,
        hdpi: ImageAttachment?,
        xhdpi: ImageAttachment?,
        xxhdpi: ImageAttachment?,
        xxxhdpi: ImageAttachment?) {
            self.assetId = assetId
            self.optimized = optimized
            self.smallScreen = smallScreen
            self.ldpi = ldpi
            self.mdpi = mdpi
            self.hdpi = hdpi
            self.xhdpi = xhdpi
            self.xxhdpi = xxhdpi
            self.xxxhdpi = xxxhdpi
    }

// MARK: NSCoding

    required init(coder decoder: NSCoder) {
        self.assetId = decoder.decodeObjectForKey("assetId") as String
        self.optimized = decoder.decodeObjectForKey("optimized") as? ImageAttachment
        self.smallScreen = decoder.decodeObjectForKey("smallScreen") as? ImageAttachment
        self.ldpi = decoder.decodeObjectForKey("ldpi") as? ImageAttachment
        self.mdpi = decoder.decodeObjectForKey("mdpi") as? ImageAttachment
        self.hdpi = decoder.decodeObjectForKey("hdpi") as? ImageAttachment
        self.xhdpi = decoder.decodeObjectForKey("xhdpi") as? ImageAttachment
        self.xxhdpi = decoder.decodeObjectForKey("xxhdpi") as? ImageAttachment
        self.xxxhdpi = decoder.decodeObjectForKey("xxxhdpi") as? ImageAttachment
    }

    func encodeWithCoder(encoder: NSCoder) {

        encoder.encodeObject(self.assetId, forKey: "assetId")
                    
        if let optimized = self.optimized {
            encoder.encodeObject(optimized, forKey: "optimized")
        }

        if let smallScreen = self.smallScreen {
            encoder.encodeObject(smallScreen, forKey: "smallScreen")
        }

        if let ldpi = self.ldpi {
            encoder.encodeObject(ldpi, forKey: "ldpi")
        }

        if let mdpi = self.mdpi {
            encoder.encodeObject(mdpi, forKey: "mdpi")
        }

        if let hdpi = self.hdpi {
            encoder.encodeObject(hdpi, forKey: "hdpi")
        }

        if let xhdpi = self.xhdpi {
            encoder.encodeObject(xhdpi, forKey: "xhdpi")
        }

        if let xxhdpi = self.xxhdpi {
            encoder.encodeObject(xxhdpi, forKey: "xxhdpi")
        }

        if let xxxhdpi = self.xxxhdpi {
            encoder.encodeObject(xxxhdpi, forKey: "xxxhdpi")
        }
    }
    
// MARK: JSONAble

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let assetId = data["id"] as? String ?? ""
        let attachment = data["attachment"] as? [String:AnyObject]
        let optimized = Asset.createImageAttachment("optimized", attachment: attachment)
        let smallScreen = Asset.createImageAttachment("small_screen", attachment: attachment)
        let ldpi = Asset.createImageAttachment("ldpi", attachment: attachment)
        let mdpi = Asset.createImageAttachment("mdpi", attachment: attachment)
        let hdpi = Asset.createImageAttachment("hdpi", attachment: attachment)
        let xhdpi = Asset.createImageAttachment("xhdpi", attachment: attachment)
        let xxhdpi = Asset.createImageAttachment("xxhdpi", attachment: attachment)
        let xxxhdpi = Asset.createImageAttachment("xxxhdpi", attachment: attachment)

        return Asset(
            assetId: assetId,
            optimized: optimized,
            smallScreen: smallScreen,
            ldpi: ldpi,
            mdpi: mdpi,
            hdpi: hdpi,
            xhdpi: xhdpi,
            xxhdpi: xxhdpi,
            xxxhdpi: xxxhdpi
        )
    }

// MARK: Private

    private class func createImageAttachment(sizeKey:String, attachment:[String: AnyObject]?) -> ImageAttachment? {

        if let attachment = attachment {
            if let size = attachment[sizeKey] as? [String:AnyObject] {
                var uri = size["url"] as String
                if uri.hasPrefix("//") {
                    uri = "https:" + uri
                }
                return ImageAttachment(
                    url: NSURL(string: uri),
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
