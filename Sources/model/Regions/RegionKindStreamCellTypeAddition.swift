//
//  RegionKindStreamCellTypeAddition.swift
//  Ello
//
//  Created by Sean on 2/9/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation

extension RegionKind {
    public func streamCellTypes(regionable: Regionable) -> [StreamCellType] {
        switch self {
        case .Image:
            return [.Image(data: regionable)]
        case .Text:
            return [.Text(data: regionable)]
        case .Embed:
            return [.Embed(data: regionable)]
        case .Unknown:
            return [.Unknown]
        }
    }
}
