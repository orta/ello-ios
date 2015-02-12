//
//  StreamCellItemParser.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

struct StreamCellItemParser {

    // MARK: - Static

    static func aspectRatioForImageBlock(imageBlock: ImageRegion) -> CGFloat {
        let width = imageBlock.asset?.hdpi?.width
        let height = imageBlock.asset?.hdpi?.height
        if width != nil && height != nil {
            return CGFloat(width!)/CGFloat(height!)
        }
        else {
            return 4.0/3.0
        }
    }

    // MARK: - public

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

    // MARK: - Private

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
        if let content = streamable.content {
            for region in content {
                var oneColumnHeight:CGFloat
                var multiColumnHeight:CGFloat

                switch region.kind {
                case .Image:
                    oneColumnHeight = self.oneColumnImageHeight(region as ImageRegion)
                    multiColumnHeight = self.twoColumnImageHeight(region as ImageRegion)
                case .Text:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                case .Unknown:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                }
                
                let body:StreamCellItem = StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.BodyElement, data: region, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight)

                cellArray.append(body)
            }
        }
        return cellArray
    }

    private func oneColumnImageHeight(imageBlock: ImageRegion) -> CGFloat {
        return UIScreen.screenWidth() / StreamCellItemParser.aspectRatioForImageBlock(imageBlock)
    }

    private func twoColumnImageHeight(imageBlock: ImageRegion) -> CGFloat {
        return ((UIScreen.screenWidth() - 10.0) / 2) / StreamCellItemParser.aspectRatioForImageBlock(imageBlock)
    }

    private func footerStreamCellItems(streamable:Streamable) -> [StreamCellItem] {
        return [StreamCellItem(streamable: streamable, type: StreamCellItem.CellType.Footer, data: nil, oneColumnCellHeight: 54.0, multiColumnCellHeight: 54.0)]
    }
}