//
//  OnboardingHeaderCellPresenter.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct OnboardingHeaderCellPresenter {

    static func configure(
        cell:UICollectionViewCell,
        streamCellItem:StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? OnboardingHeaderCell,
            let (header, message) = streamCellItem.data as? (String, String)
        {
            cell.header = header
            cell.message = message

            if streamCellItem.oneColumnCellHeight != cell.height() {
                streamCellItem.oneColumnCellHeight = cell.height()
                streamCellItem.multiColumnCellHeight = cell.height()
                postNotification(StreamNotification.UpdateCellHeightNotification, cell)
            }
        }
    }
}
