//
//  StreamRepostHeaderCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct StreamRepostHeaderCellPresenter {

    static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamRepostHeaderCell {
            let post = streamCellItem.jsonable as! Post
            cell.viaTextView.clearText()
            cell.sourceTextView.clearText()
            if let repostViaPath = post.repostViaPath where post.repostViaId != nil {
                let components = repostViaPath.componentsSeparatedByString("/").filter { !$0.isEmpty }
                if let username = components.first {
                    cell.viaTextViewHeight.constant = 15.0
                    cell.viaTextView.appendTextWithAction("Via: @\(username)", link: "userId", object: "~\(username)")
                } else {
                    cell.viaTextViewHeight.constant = 0.0
                }
            } else {
                cell.viaTextViewHeight.constant = 0.0
            }
            if let repostPath = post.repostPath where post.repostId != nil {
                let components = repostPath.componentsSeparatedByString("/").filter { !$0.isEmpty }
                if let username = components.first {
                    cell.sourceTextView.appendTextWithAction("Source: @\(username)", link: "userId", object: "~\(username)")
                }
            }
        }
    }
}
