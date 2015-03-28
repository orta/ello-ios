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

final class ImageRegion: JSONAble, NSCoding {

    let version: Int = ImageRegionVersion

    let asset:Asset?
    var alt:String?
    let url:NSURL?

// MARK: Initialization

    init(asset: Asset?,
        alt: String?,
        url: NSURL?) {
            self.asset = asset
            self.alt = alt
            self.url = url
    }

// MARK: NSCoding

    func encodeWithCoder(encoder: NSCoder) {
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

    required init(coder decoder: NSCoder) {
        self.asset = decoder.decodeObjectForKey("asset") as? Asset
        self.alt = decoder.decodeObjectForKey("alt") as? String
        self.url = decoder.decodeObjectForKey("url") as? NSURL
    }

// MARK: JSONAble

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
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
