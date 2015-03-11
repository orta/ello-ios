//
//  TextRegionExtensions.swift
//  Ello
//
//  Created by Sean on 2/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension TextRegion: Regionable {
    var kind:RegionKind { return RegionKind.Text }

    func toJSON() -> [String: AnyObject] {
        return [
            "kind": self.kind.rawValue,
            "data": self.content
        ]
    }
}