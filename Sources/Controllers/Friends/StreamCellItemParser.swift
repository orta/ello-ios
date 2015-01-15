//
//  StreamCellItemParser.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

struct StreamCellItemParser {

    func streamCellItems(activities:[Activity]) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for activity in activities {
            cellItems += headerStreamCellItems(activity)
            cellItems += bodyStreamCellItems(activity)
            if activity.kind != Activity.Kind.WelcomePost {
                cellItems += footerStreamCellItems(activity)
            }
        }
        return cellItems
    }

    private func headerStreamCellItems(activity:Activity) -> [StreamCellItem] {
        return [StreamCellItem(activity: activity, type: StreamCellItem.CellType.Header, data: nil, cellHeight: 80.0)]
    }

    private func bodyStreamCellItems(activity:Activity) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        if let post = activity.subject as? Post {
            for block in post.content {
                var height:CGFloat
                switch block.kind {
                case Block.Kind.Image:
                    height = UIScreen.screenWidth() / (4/3)
                case Block.Kind.Text:
                    height = 0
                case Block.Kind.Unknown:
                    height = 120.0
                }

                let body:StreamCellItem = StreamCellItem(activity: activity, type: StreamCellItem.CellType.BodyElement, data: block, cellHeight: height)
                cellArray.append(body)
            }
        }
        return cellArray
    }

    private func footerStreamCellItems(activity:Activity) -> [StreamCellItem] {
        return [StreamCellItem(activity: activity, type: StreamCellItem.CellType.Footer, data: nil, cellHeight: 54.0)]
    }
}