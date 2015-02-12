//
//  StreamCellItem.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

class StreamCellItem {

    enum CellType {
        case Header
        case CommentHeader
        case Footer
        case BodyElement
        case CommentBodyElement
    }

//    let comment:Comment?
    let streamable:Streamable
    let type:StreamCellItem.CellType
    let data:Regionable?
    var oneColumnCellHeight:CGFloat = 0
    var multiColumnCellHeight:CGFloat = 0

    init(streamable:Streamable, type:StreamCellItem.CellType, data:Regionable?, oneColumnCellHeight:CGFloat, multiColumnCellHeight:CGFloat) {
        self.streamable = streamable
        self.type = type
        self.data = data
        self.oneColumnCellHeight = oneColumnCellHeight
        self.multiColumnCellHeight = multiColumnCellHeight
    }
}