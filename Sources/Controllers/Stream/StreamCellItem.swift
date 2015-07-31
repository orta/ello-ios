//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public enum StreamCellState: Printable, DebugPrintable {
    case None
    case Loading
    case Expanded
    case Collapsed

    public var description: String {
        switch self {
        case None: return "None"
        case Loading: return "Loading"
        case Expanded: return "Expanded"
        case Collapsed: return "Collapsed"
        }
    }
    public var debugDescription: String { return "StreamCellState.\(description)" }
}


public final class StreamCellItem: NSObject, NSCopying {
    public var jsonable: JSONAble
    public var type: StreamCellType
    public var calculatedWebHeight: CGFloat?
    public var calculatedOneColumnCellHeight: CGFloat?
    public var calculatedMultiColumnCellHeight: CGFloat?
    public var state: StreamCellState = .None

    public required init(jsonable: JSONAble, type: StreamCellType) {
        self.jsonable = jsonable
        self.type = type
    }

    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType(
            jsonable: self.jsonable,
            type: self.type
            )
        copy.calculatedWebHeight = self.calculatedWebHeight
        copy.calculatedOneColumnCellHeight = self.calculatedOneColumnCellHeight
        copy.calculatedMultiColumnCellHeight = self.calculatedMultiColumnCellHeight
        return copy
    }

    public func alwaysShow() -> Bool {
        if type == .StreamLoading {
            return true
        }
        return false
    }

}
