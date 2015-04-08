//
//  StreamCellItemParser.swift
//  Ello
//
//  Created by Sean Dougherty on 12/16/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public struct StreamCellItemParser {

    public init(){}

    public func parse(items: [JSONAble], streamKind: StreamKind) -> [StreamCellItem] {
        var filteredItems = streamKind.filter(items)
        if let posts = filteredItems as? [Post] {
            return postCellItems(posts, streamKind: streamKind)
        }
        if let comments = filteredItems as? [Comment] {
            return commentCellItems(comments)
        }
        if let notifications = filteredItems as? [Notification] {
            return notificationCellItems(notifications)
        }
        if let users = filteredItems as? [User] {
            return userCellItems(users)
        }
        return []
    }

    // MARK: - Static

    public static func aspectRatioForImageBlock(imageBlock: ImageRegion) -> CGFloat {
        let width = imageBlock.asset?.hdpi?.width
        let height = imageBlock.asset?.hdpi?.height
        if width != nil && height != nil {
            return CGFloat(width!)/CGFloat(height!)
        }
        else {
            return 4.0/3.0
        }
    }

    // MARK: - Private

    private func notificationCellItems(notifications:[Notification]) -> [StreamCellItem] {
        return map(notifications) { notification in
            return StreamCellItem(
                jsonable: notification,
                type: .Notification,
                data: nil,
                oneColumnCellHeight: 107.0,
                multiColumnCellHeight: 49.0,
                isFullWidth: false
            )
        }
    }

    private func postCellItems(posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for post in posts {
            cellItems.append(StreamCellItem(jsonable: post, type: StreamCellType.Header, data: nil, oneColumnCellHeight: 80.0, multiColumnCellHeight: 49.0, isFullWidth: false))
            cellItems += postToggleItems(post, streamKind: streamKind)
            cellItems += postRegionItems(post, streamKind: streamKind)
            cellItems += footerStreamCellItems(post)
        }
        return cellItems
    }

    private func commentCellItems(comments: [Comment]) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for comment in comments {
            cellItems.append(StreamCellItem(jsonable: comment, type: StreamCellType.CommentHeader, data: nil, oneColumnCellHeight: 50.0, multiColumnCellHeight: 50.0, isFullWidth: false))
            cellItems += commentRegionItems(comment)
        }
        return cellItems
    }

    private func postToggleItems(post: Post, streamKind: StreamKind) -> [StreamCellItem] {
        if post.collapsed {
            return [StreamCellItem(jsonable: post, type: StreamCellType.Toggle, data: nil, oneColumnCellHeight: 30.0, multiColumnCellHeight: 30.0, isFullWidth: false)]
        }
        else {
            return []
        }
    }

    private func postRegionItems(post: Post, streamKind: StreamKind) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        let contentKind = streamKind.isGridLayout ? post.summary : post.content
        if let content = contentKind {
            for region in content {
                var oneColumnHeight:CGFloat
                var multiColumnHeight:CGFloat
                var type : StreamCellType

                let kind = RegionKind(rawValue: region.kind) ?? RegionKind.Unknown

                switch kind {
                case .Image:
                    oneColumnHeight = self.oneColumnImageHeight(region as! ImageRegion)
                    multiColumnHeight = self.twoColumnImageHeight(region as! ImageRegion)
                    type = .Image
                case .Text:
                    oneColumnHeight = 0.0
                    multiColumnHeight = 0.0
                    type = .Text
                case .Embed, .Unknown:
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

        for region in comment.content {
            var oneColumnHeight:CGFloat
            var multiColumnHeight:CGFloat
            var type : StreamCellType

            let kind = RegionKind(rawValue: region.kind) ?? RegionKind.Unknown

            switch kind {
            case .Image:
                oneColumnHeight = self.oneColumnImageHeight(region as! ImageRegion)
                multiColumnHeight = self.twoColumnImageHeight(region as! ImageRegion)
                type = .Image
            case .Text:
                oneColumnHeight = 0.0
                multiColumnHeight = 0.0
                type = .Text
            case .Embed, .Unknown:
                oneColumnHeight = 0.0
                multiColumnHeight = 0.0
                type = .Unknown
            }

            let body:StreamCellItem = StreamCellItem(jsonable: comment, type: type, data: region, oneColumnCellHeight: oneColumnHeight, multiColumnCellHeight: multiColumnHeight, isFullWidth: false)

            cellArray.append(body)
        }
        return cellArray
    }

    private func userCellItems(users: [User]) -> [StreamCellItem] {
        return map(users) { user in
            return StreamCellItem(
                jsonable: user,
                type: .UserListItem,
                data: nil,
                oneColumnCellHeight: 56.0,
                multiColumnCellHeight: 56.0,
                isFullWidth: true
            )
        }
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