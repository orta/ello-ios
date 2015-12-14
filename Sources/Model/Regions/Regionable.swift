//
//  Regionable.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol Regionable {
    var kind:String { get }
    var isRepost: Bool { get set }
    func toJSON() -> [String: AnyObject]
    func coding() -> NSCoding
}

public enum RegionKind: String {
    case Text = "text"
    case Image = "image"
    case Embed = "embed"
    case Unknown = "Unknown"

    public func streamCellType(regionable: Regionable) -> StreamCellType {
        switch self {
        case .Image:
            return .Image(data: regionable)
        case .Text:
            return .Text(data: regionable)
        case .Embed:
            return .Embed(data: regionable)
        case .Unknown:
            return .Unknown
        }
    }
}
