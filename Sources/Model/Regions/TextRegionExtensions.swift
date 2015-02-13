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
}

extension TextRegion : JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let content = json["data"].stringValue
        return TextRegion(content: content)
    }
    
}