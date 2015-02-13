//
//  ImageRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

class ImageRegion: JSONAble {
    let asset:Asset?
    let alt:String
    let url:NSURL?

    init(asset: Asset?,
        alt: String,
        url: NSURL?) {
            self.asset = asset
            self.alt = alt
            self.url = url
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let alt = json["data"].object["alt"] as String
        let url = json["data"].object["url"] as String
        var links = [String: AnyObject]()
        var asset:Asset?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            asset = links["assets"] as? Asset
        }

        return ImageRegion(asset: asset, alt: alt, url: NSURL(string: url))
    }
}