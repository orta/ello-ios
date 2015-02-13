//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

class StreamCellItem {

    let jsonable: JSONAble
    let type: StreamCellType
    let data: Block?
    let isFullWidth: Bool
    var oneColumnCellHeight: CGFloat = 0
    var multiColumnCellHeight: CGFloat = 0

    init(jsonable: JSONAble, type:StreamCellType, data:Block?, oneColumnCellHeight:CGFloat, multiColumnCellHeight:CGFloat, isFullWidth: Bool) {
        self.jsonable = jsonable
        self.type = type
        self.data = data
        self.isFullWidth = isFullWidth
        self.oneColumnCellHeight = oneColumnCellHeight
        self.multiColumnCellHeight = multiColumnCellHeight
    }
}