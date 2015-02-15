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

    func postCellItems(posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for post in posts {
            cellItems += [StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 80.0, multiColumnCellHeight: 49.0, isFullWidth: false)]
            cellItems += postRegionItems(post, streamKind: streamKind)
            cellItems += footerStreamCellItems(post)
        }
        return cellItems
    }

    func commentCellItems(comments: [Comment]) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for comment in comments {
            cellItems += [StreamCellItem(jsonable: comment, type: StreamCellType.CommentHeader, data: nil, oneColumnCellHeight: 50.0, multiColumnCellHeight: 50.0, isFullWidth: false)]
            cellItems += commentRegionItems(comment)
        }
        return cellItems
    }

    // MARK: - Private
    private func postRegionItems(post: Post, streamKind: StreamKind) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        let contentKind = streamKind.isGridLayout ? post.summary : post.content
        if let content = contentKind {
            for region in content {
                var oneColumnHeight:CGFloat
                var multiColumnHeight:CGFloat
                var type : StreamCellType

                switch region.kind {
                case .Image:
                    oneColumnHeight = self.oneColumnImageHeight(region as ImageRegion)
                    multiColumnHeight = self.twoColumnImageHeight(region as ImageRegion)
                    type = .Image
                case .Text:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                    type = .Text
                case .Unknown:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                    type = .Unknown
                }

                if type != .Unknown {
                    let body:StreamCellItem = StreamCellItem(jsonable: post, type: type, data: region, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight, isFullWidth: false)

                    cellArray.append(body)
                }
            }
        }
        return cellArray
    }


    private func commentRegionItems(comment: Comment) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        if let content = comment.content {
            for region in content {
                var oneColumnHeight:CGFloat
                var multiColumnHeight:CGFloat
                var type : StreamCellType

                switch region.kind {
                case .Image:
                    oneColumnHeight = self.oneColumnImageHeight(region as ImageRegion)
                    multiColumnHeight = self.twoColumnImageHeight(region as ImageRegion)
                    type = .Image
                case .Text:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                    type = .Text
                case .Unknown:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                    type = .Unknown
                }

                let body:StreamCellItem = StreamCellItem(jsonable: comment, type: type, data: region, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight, isFullWidth: false)

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

    private func footerStreamCellItems(post: Post) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: post, type: StreamCellType.Footer, data: nil, oneColumnCellHeight: 54.0, multiColumnCellHeight: 54.0, isFullWidth: false)]
    }
}