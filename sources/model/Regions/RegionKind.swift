//
//  RegionKind.swift
//  Ello
//
//  Created by Sean on 2/2/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

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
