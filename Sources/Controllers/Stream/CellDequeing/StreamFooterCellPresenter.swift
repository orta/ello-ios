//
//  StreamFooterCellPresenter.swift
//  Ello
//
//  Created by Sean on 2/18/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct StreamFooterCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath)
    {
        if let cell = cell as? StreamFooterCell {
            if let post = streamCellItem.jsonable as? Post {
                cell.comments = post.commentsCount?.localizedStringFromNumber()

                cell.commentsButton.finishAnimation()

                if streamKind.isDetail {
                    cell.commentsOpened = true
                }

                cell.scrollView.scrollEnabled = !streamKind.isGridLayout
                cell.chevronButton.hidden = streamKind.isGridLayout
                
                if streamKind.isGridLayout {
                    cell.views = ""
                    cell.reposts = ""
                }
                else {
                    cell.views = post.viewsCount?.localizedStringFromNumber()
                    cell.reposts = post.repostsCount?.localizedStringFromNumber()
                }
                cell.streamKind = streamKind
            }
        }
    }
}