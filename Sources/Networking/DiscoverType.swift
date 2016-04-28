//
//  DiscoverType.swift
//  Ello
//
//  Created by Colin Gray on 2/23/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public enum DiscoverType: String {
    case Recommended = "recommended"
    case Trending = "trending"
    case Recent = "recent"

    public var name: String {
        switch self {
        case Recommended: return InterfaceString.Discover.Featured
        case Trending: return InterfaceString.Discover.Trending
        case Recent: return InterfaceString.Discover.Recent
        }
    }
}
