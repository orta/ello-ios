//
//  Regionable.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

@objc protocol Regionable {
    var kind:String { get }
    func toJSON() -> [String: AnyObject]
    func coding() -> NSCoding
}

enum RegionKind: String {
    case Text = "text"
    case Image = "image"
    case Unknown = "Unknown"
}
