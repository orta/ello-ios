//
//  UnknownRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let UnknownRegionVersion = 1

final class UnknownRegion: NSObject, Regionable, NSCoding {

    let version: Int = UnknownRegionVersion

    var kind:String { return RegionKind.Unknown.rawValue }

    func coding() -> NSCoding {
        return self
    }

    // no-op initializer to allow stubbing
    init(name: String) {}


// MARK: NSCoding

    func encodeWithCoder(encoder: NSCoder) {
    }

    required init(coder decoder: NSCoder) {

    }

    func toJSON() -> [String: AnyObject] {
        return [:]
    }
}
