//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public enum StreamCellState {
    case None
    case Loading
    case Expanded
    case Collapsed
}


public class StreamCellItem: NSObject, NSCopying {
    public let jsonable: JSONAble
    public let type: StreamCellType
    public let data:Regionable?
    public let isFullWidth: Bool
    public var calculatedWebHeight: CGFloat = 0
    public var oneColumnCellHeight: CGFloat = 0
    public var multiColumnCellHeight: CGFloat = 0
    public var state: StreamCellState = .None

    public required init(jsonable: JSONAble, type:StreamCellType, data:Regionable?, oneColumnCellHeight:CGFloat, multiColumnCellHeight:CGFloat, isFullWidth: Bool) {
        self.jsonable = jsonable
        self.type = type
        self.data = data
        self.isFullWidth = isFullWidth
        self.calculatedWebHeight = 0
        self.oneColumnCellHeight = oneColumnCellHeight
        self.multiColumnCellHeight = multiColumnCellHeight
    }

    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType(
            jsonable: self.jsonable,
            type: self.type,
            data: self.data,
            oneColumnCellHeight: self.oneColumnCellHeight,
            multiColumnCellHeight: self.multiColumnCellHeight,
            isFullWidth: self.isFullWidth
            )
        copy.calculatedWebHeight = self.calculatedWebHeight
        return copy
    }

}
