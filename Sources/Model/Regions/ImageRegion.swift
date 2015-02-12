//
//  ImageRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct ImageRegion: Regionable {

    var kind:RegionKind {
        get { return RegionKind.Image }
    }

    let asset:Asset?
    let assetId:String?
    let alt:String
    let url:NSURL?
}