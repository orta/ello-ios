//
//  Regionable.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

@objc
public protocol Regionable {
    var kind:String { get }
    func toJSON() -> [String: AnyObject]
    func coding() -> NSCoding
}

public enum RegionKind: String {
    case Text = "text"
    case Image = "image"
    case Embed = "embed"
    case Unknown = "Unknown"
}
