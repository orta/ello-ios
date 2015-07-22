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
            cellItems += postToggleItems(post)
            if post.isRepost {
                // add repost header with via/source
                var repostHeaderHeight: CGFloat = post.repostViaPath == nil ? 15.0 : 30.0
                cellItems.append(StreamCellItem(jsonable: post, type: StreamCellType.RepostHeader, data: nil, oneColumnCellHeight: repostHeaderHeight, multiColumnCellHeight: repostHeaderHeight, isFullWidth: false))
                // add repost content
                // this is weird, but the post summary is actually the repost summary on reposts
                if streamKind.isGridLayout {
                    cellItems += regionItems(post, content: post.summary)
                }
                else if let repostContent = post.repostContent {
                    cellItems += regionItems(post, content: repostContent)
                    // add additional content
                    if let content = post.content {
                        cellItems += regionItems(post, content: content)
                    }
                }
            }
            else {
                if let content = streamKind.isGridLayout ? post.summary : post.content {
                    cellItems += regionItems(post, content: content)
                }
            }
            cellItems += footerStreamCellItems(post)
        }
        // set initial state on the items, but don't toggle the footer's state, it is used by comment open/closed
        for item in cellItems {
            if let post = item.jsonable as? Post where item.type != .Footer {
                item.state = post.collapsed ? .Collapsed : .Expanded
            }
        }
        return cellItems
    }

    private func commentCellItems(comments: [Comment]) -> [StreamCellItem] {
        var cellItems:[StreamCellItem] = []
        for comment in comments {
            cellItems.append(StreamCellItem(jsonable: comment, type: StreamCellType.CommentHeader, data: nil, oneColumnCellHeight: 50.0, multiColumnCellHeight: 50.0, isFullWidth: false))
            cellItems += regionItems(comment, content: comment.content)
        }
        return cellItems
    }

    private func postToggleItems(post: Post) -> [StreamCellItem] {
        if post.collapsed {
            return [StreamCellItem(jsonable: post, type: StreamCellType.Toggle, data: nil, oneColumnCellHeight: 30.0, multiColumnCellHeight: 30.0, isFullWidth: false)]
        }
        else {
            return []
        }
    }

    private func regionItems(jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        var cellArray:[StreamCellItem] = []
        for region in content {
            let kind = RegionKind(rawValue: region.kind) ?? RegionKind.Unknown
            let type = kind.streamCellType
            if type != .Unknown {
                let item: StreamCellItem = StreamCellItem(jsonable: jsonable, type: type, data: region, oneColumnCellHeight: 0.0, multiColumnCellHeight: 0.0, isFullWidth: false)
                cellArray.append(item)
            }
        }
        return cellArray
    }

    private func userCellItems(users: [User]) -> [StreamCellItem] {
        return map(users) { user in
            return StreamCellItem(
                jsonable: user,
                type: .UserListItem,
                data: nil,
                oneColumnCellHeight: 75.0,
                multiColumnCellHeight: 75.0,
                isFullWidth: true
            )
        }
    }

    private func footerStreamCellItems(post: Post) -> [StreamCellItem] {
        return [StreamCellItem(jsonable: post, type: StreamCellType.Footer, data: nil, oneColumnCellHeight: 54.0, multiColumnCellHeight: 54.0, isFullWidth: false)]
    }
}


// MARK: For Testing
public extension StreamCellItemParser {
    public func testingNotificationCellItems(notifications:[Notification]) -> [StreamCellItem] {
        return notificationCellItems(notifications)
    }
    public func testingPostCellItems(posts: [Post], streamKind: StreamKind) -> [StreamCellItem] {
        return postCellItems(posts, streamKind: streamKind)
    }
    public func testingCommentCellItems(comments: [Comment]) -> [StreamCellItem] {
        return commentCellItems(comments)
    }
    public func testingPostToggleItems(post: Post) -> [StreamCellItem] {
        return postToggleItems(post)
    }
    public func testingRegionItems(jsonable: JSONAble, content: [Regionable]) -> [StreamCellItem] {
        return regionItems(jsonable, content: content)
    }
    public func testingUserCellItems(users: [User]) -> [StreamCellItem] {
        return userCellItems(users)
    }
    public func testingFooterStreamCellItems(post: Post) -> [StreamCellItem] {
        return footerStreamCellItems(post)
    }
}

