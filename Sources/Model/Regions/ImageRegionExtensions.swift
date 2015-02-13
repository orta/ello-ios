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