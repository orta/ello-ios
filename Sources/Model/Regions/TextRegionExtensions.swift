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
    var kind:String { return RegionKind.Text.rawValue }
    func coding() -> NSCoding {
        return self
    }
	
	func toJSON() -> [String: AnyObject] {
        return [
            "kind": self.kind,
            "data": self.content
        ]
    }
}

