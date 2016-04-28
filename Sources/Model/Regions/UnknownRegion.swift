//
//  UnknownRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let UnknownRegionVersion = 1

@objc(UnknownRegion)
public final class UnknownRegion: NSObject, Regionable, NSCoding {
    public let version = UnknownRegionVersion
    public var isRepost: Bool = false

    public var kind:String { return RegionKind.Unknown.rawValue }

    public func coding() -> NSCoding {
        return self
    }

    // no-op initializer to allow stubbing
    public init(name: String) {}


// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
    }

    required public init?(coder decoder: NSCoder) {

    }

    public func toJSON() -> [String: AnyObject] {
        return [:]
    }
}
