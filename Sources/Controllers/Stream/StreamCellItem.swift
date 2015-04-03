//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public class StreamCellItem:NSObject {

    public let jsonable: JSONAble
    public let type: StreamCellType
    public let data:Regionable?
    public let isFullWidth: Bool
    public var calculatedWebHeight: CGFloat = 0
    public var oneColumnCellHeight: CGFloat = 0
    public var multiColumnCellHeight: CGFloat = 0

    public init(jsonable: JSONAble, type:StreamCellType, data:Regionable?, oneColumnCellHeight:CGFloat, multiColumnCellHeight:CGFloat, isFullWidth: Bool) {
        self.jsonable = jsonable
        self.type = type
        self.data = data
        self.isFullWidth = isFullWidth
        self.calculatedWebHeight = 0
        self.oneColumnCellHeight = oneColumnCellHeight
        self.multiColumnCellHeight = multiColumnCellHeight
    }
}
