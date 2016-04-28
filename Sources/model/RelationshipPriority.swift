//
//  RelationshipPriority.swift
//  Ello
//
//  Created by Sean on 2/1/16.
//  Copyright © 2016 Ello. All rights reserved.
//


public enum RelationshipPriority: String {
    case Following = "friend"
    case Starred = "noise"
    case Block = "block"
    case Mute = "mute"
    case Inactive = "inactive"
    case None = "none"
    case Null = "null"
    case Me = "self"

    static let all = [Following, Starred, Block, Mute, Inactive, None, Null, Me]

    public init(stringValue: String) {
        self = RelationshipPriority(rawValue: stringValue) ?? .None
    }

    var buttonName: String {
        switch self {
        case .Following: return "following"
        case .Starred: return "starred"
        default: return self.rawValue
        }
    }
}
