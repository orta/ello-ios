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

    func toJSON() -> [String: AnyObject] {
        if let url : String = self.url?.absoluteString {
            return [
                "kind": self.kind.rawValue,
                "data": [
                    "alt": alt ?? "",
                    "via": "direct",
                    "url": url
                ],
            ]
        }
        else {
            return [
                "kind": self.kind.rawValue,
                "data": [:]
            ]
        }
    }
}