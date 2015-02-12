//
//  RegionParser.swift
//  Ello
//
//  Created by Sean on 1/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

struct RegionParser {

    static func regions(json: JSON, assets: [String:JSONAble]?) -> [Regionable] {
        let content = json["content"].object as [AnyObject]
        return content.map { (contentDict) -> Regionable in
            let kind = RegionKind(rawValue: contentDict["kind"] as String) ?? RegionKind.Unknown
            let data = contentDict["data"]
            switch kind {
            case .Text:
                let data = data as String
                return TextRegion(content: data)
            case .Image:
                let data = data as [String:AnyObject]
                let alt = data["alt"] as? String ?? ""
                let url = data["url"] as String
                let assetId = data["asset_id"] as? String

                var asset:Asset?
                if let (assetId, assets) = unwrap(assetId, assets) {
                    asset = assets[assetId] as? Asset
                }
                return ImageRegion(asset:asset, assetId: assetId, alt: alt, url: NSURL(string: url)!)

            case .Unknown:
                return UnknownRegion()
            }
        }
    }



}