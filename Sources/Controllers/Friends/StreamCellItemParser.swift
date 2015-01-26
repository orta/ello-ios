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
        var height:CGFloat
        switch streamable.kind {
        case .Comment:
            type = StreamCellItem.CellType.CommentHeader
            height = 50.0
        default:
            height = 80.0
        }
        
        return [StreamCellItem(streamable: streamable, type: type, data: nil, cellHeight: height)]
    }

    private func regionStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        for block in streamable.content {
            var height:CGFloat
            switch block.kind {
            case Block.Kind.Image:
                height = UIScreen.screenWidth() / (4/3)
            case Block.Kind.Text:
                height = 0
            case Block.Kind.Unknown:
                height = 0.0
            }
            
            let body:StreamCellItem = StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.BodyElement, data: block, cellHeight: height)
            cellArray.append(body)
        }
        return cellArray
    }

    private func footerStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        return [StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.Footer, data: nil, cellHeight: 54.0)]
    }
}