//
//  StreamTextCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct StreamTextCellPresenter {
    static let commentMargin = CGFloat(60)
    static let postMargin = CGFloat(15)
    static let repostMargin = CGFloat(30)

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamTextCell {
            cell.onWebContentReady { webView in
                if let actualHeight = webView.windowContentSize()?.height where actualHeight != streamCellItem.calculatedWebHeight {
                    streamCellItem.calculatedWebHeight = actualHeight
                    streamCellItem.calculatedOneColumnCellHeight = actualHeight
                    streamCellItem.calculatedMultiColumnCellHeight = actualHeight
                    postNotification(StreamNotification.UpdateCellHeightNotification, cell)
                }
            }
            cell.hideBorder()
            var isRepost = false
            cell.webView.loadHTMLString("", baseURL: NSURL(string: "/"))
            if let textRegion = streamCellItem.type.data as? TextRegion {
                isRepost = textRegion.isRepost
                let content = textRegion.content
                let html = StreamTextCellHTML.postHTML(content)
                cell.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            // Repost specifics
            if isRepost == true {
                cell.leadingConstraint.constant = 30.0
                cell.showBorder()
            }
            else if let comment = streamCellItem.jsonable as? Comment {
                cell.leadingConstraint.constant = commentMargin
            }
            else {
                cell.leadingConstraint.constant = postMargin
            }
        }
    }

}
