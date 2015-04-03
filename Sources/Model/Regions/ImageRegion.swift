//
//  ImageRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let ImageRegionVersion = 1

public final class ImageRegion: JSONAble, NSCoding {

    public let version: Int = ImageRegionVersion

    public let asset:Asset?
    public var alt:String?
    public let url:NSURL?

// MARK: Initialization

    public init(asset: Asset?,
        alt: String?,
        url: NSURL?) {
            self.asset = asset
            self.alt = alt
            self.url = url
    }

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        if let asset = self.asset {
            encoder.encodeObject(asset, forKey: "asset")
        }

        if let alt = self.alt {
            encoder.encodeObject(alt, forKey: "alt")
        }

        if let url = self.url {
            encoder.encodeObject(url, forKey: "url")
        }
    }

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.asset = decoder.decodeOptionalKey("asset")
        self.alt = decoder.decodeOptionalKey("alt")
        self.url = decoder.decodeOptionalKey("url")
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        var alt = json["data"].object["alt"] as? String
        let url = json["data"].object["url"] as! String
        var links = [String: AnyObject]()
        var asset:Asset?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            asset = links["assets"] as? Asset
        }

        return ImageRegion(asset: asset, alt: alt, url: NSURL(string: url))
    }
}
