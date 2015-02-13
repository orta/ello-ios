//
//  ImageRegionExtensions.swift
//  Ello
//
//  Created by Sean on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ImageRegion: Regionable {
    var kind:RegionKind {
        get { return RegionKind.Image }
    }
}

extension ImageRegion: JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let alt = json["data"].object["alt"] as String
        let url = json["data"].object["url"] as String
        var links = [String: Any]()
        var asset:Asset?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            asset = links["assets"] as? Asset
            println("asset = \(asset)")
        }

        return ImageRegion(asset: asset, alt: alt, url: NSURL(string: url))
    }

}