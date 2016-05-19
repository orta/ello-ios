//
//  RegionParser.swift
//  Ello
//
//  Created by Sean on 1/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON

public struct RegionParser {

    public static func regions(key: String, json: JSON, isRepostContent: Bool = false) -> [Regionable] {
        if let content = json[key].object as? [[String:AnyObject]] {
            return content.map { (contentDict) -> Regionable in
                let kind = RegionKind(rawValue: contentDict["kind"] as! String) ?? RegionKind.Unknown
                var regionable: Regionable!
                switch kind {
                case .Text:
                    regionable = TextRegion.fromJSON(contentDict) as! TextRegion
                case .Image:
                    regionable = ImageRegion.fromJSON(contentDict) as! ImageRegion
                case .Embed:
                    regionable = EmbedRegion.fromJSON(contentDict) as! EmbedRegion
                default:
                    regionable = UnknownRegion(name: "Unknown")
                }
                regionable.isRepost = isRepostContent
                return regionable
            }
        }
        else {
            return []
        }
    }
}
