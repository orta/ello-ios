//
//  RegionParser.swift
//  Ello
//
//  Created by Sean on 1/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

public struct RegionParser {

    public static func regions(key:String, json: JSON) -> [Regionable] {
        if let content = json[key].object as? [[String:AnyObject]] {
            return content.map { (contentDict) -> Regionable in
                let kind = RegionKind(rawValue: contentDict["kind"] as! String) ?? RegionKind.Unknown
                switch kind {
                case .Text:
                    return TextRegion.fromJSON(contentDict) as! TextRegion
                case .Image:
                    return ImageRegion.fromJSON(contentDict) as! ImageRegion
                case .Unknown:
                    return UnknownRegion(name: "Unknown")
                }
            }
        }
        else {
            return []
        }
    }
}
