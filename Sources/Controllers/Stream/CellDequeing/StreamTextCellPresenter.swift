//
//  StreamTextCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

struct StreamTextCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? StreamTextCell {
            cell.contentView.alpha = 0.0
            cell.webView.scrollView.scrollEnabled = false

            if let textData = streamCellItem.data as TextRegion? {
                cell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
            }

            if let comment = streamCellItem.jsonable as? Comment {
                cell.leadingConstraint.constant = 58.0
            }
            else {
                cell.leadingConstraint.constant = 0.0
            }
        }
    }

}