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

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamTextCell {
            cell.onWebContentReady { webView in
                if let actualHeight = webView.windowContentSize()?.height {
                    if actualHeight != streamCellItem.calculatedWebHeight {
                        streamCellItem.multiColumnCellHeight = actualHeight
                        streamCellItem.oneColumnCellHeight = actualHeight
                        streamCellItem.calculatedWebHeight = actualHeight
                        postNotification(StreamNotification.UpdateCellHeightNotification, cell)
                    }
                }
            }
            cell.hideBorder()
            // Repost specifics
            if streamCellItem.region?.isRepost == true {
                cell.leadingConstraint.constant = 30.0
                cell.showBorder()
            }
            else if let comment = streamCellItem.jsonable as? Comment {
                cell.leadingConstraint.constant = commentMargin
            }
            else {
                cell.leadingConstraint.constant = postMargin
            }

            if let textRegion = streamCellItem.data as? TextRegion {
                let content = textRegion.content
                let html = StreamTextCellHTML.postHTML(content)
                cell.webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
            }
            else {
                cell.webView.loadHTMLString("", baseURL: NSURL(string: "/"))
            }
        }
    }

}
