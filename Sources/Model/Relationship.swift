//
//  Relationship.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public enum Relationship: String {
    case Friend = "friend"
    case Noise = "noise"
    case Block = "block"
    case Mute = "mute"
    case Inactive = "inactive"
    case None = "none"
    case Null = "null"
    case Me = "self"

    static let all = [Friend, Noise, Block, Mute, Inactive, None, Null, Me]

    public init(stringValue: String) {
        self = Relationship(rawValue: stringValue) ?? .None
    }
}
