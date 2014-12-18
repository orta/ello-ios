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
        case Footer
        case BodyElement
    }

    let activity:Activity
    let type:StreamCellItem.CellType
    let data:Post.BodyElement?
    var cellHeight:CGFloat = 0

    init(activity:Activity, type:StreamCellItem.CellType, data:Post.BodyElement?, cellHeight:CGFloat) {
        self.activity = activity
        self.type = type
        self.data = data
        self.cellHeight = cellHeight
    }
}