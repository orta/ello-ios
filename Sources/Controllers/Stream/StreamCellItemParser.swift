//
//  StreamCellItemParser.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

struct StreamCellItemParser {

    func streamCellItems(streamables:[Streamable]) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for streamable in streamables {
            cellItems += headerStreamCellItems(streamable)
            cellItems += regionStreamCellItems(streamable)
            if streamable.kind == StreamableKind.Post {
                cellItems += footerStreamCellItems(streamable)
            }
        }
        return cellItems
    }

    private func headerStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        
        var type = StreamCellItem.CellType.Header
        var oneColumnHeight:CGFloat
        var multiColumnHeight:CGFloat
        switch streamable.kind {
        case .Comment:
            type = StreamCellItem.CellType.CommentHeader
            oneColumnHeight = 50.0
            multiColumnHeight = 50.0
        default:
            oneColumnHeight = 80.0
            multiColumnHeight = 49.0
        }
        
        return [StreamCellItem(streamable: streamable, type: type, data: nil, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight)]
    }

    private func regionStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        for block in streamable.content {
            var oneColumnHeight:CGFloat
            var multiColumnHeight:CGFloat
            switch block.kind {
            case Block.Kind.Image:
                oneColumnHeight = UIScreen.screenWidth() / (4/3)
                multiColumnHeight = UIScreen.screenWidth() / (4/3)
            case Block.Kind.Text:
                oneColumnHeight = 0.0
                multiColumnHeight = 0.0
            case Block.Kind.Unknown:
                oneColumnHeight = 0.0
                multiColumnHeight = 0.0
            }
            
            let body:StreamCellItem = StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.BodyElement, data: block, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight)
            cellArray.append(body)
        }
        return cellArray
    }

    private func footerStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        return [StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.Footer, data: nil, oneColumnCellHeight: 54.0, multiColumnCellHeight: 54.0)]
    }
}