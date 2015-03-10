//
//  StreamCellType.swift
//  Ello
//
//  Created by Sean on 2/7/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

typealias CellConfigClosure = (
    cell:UICollectionViewCell,
    streamCellItem:StreamCellItem,
    streamKind: StreamKind,
    indexPath: NSIndexPath
) -> ()

enum StreamCellType {
    case CommentHeader
    case Header
    case Footer
    case Image
    case Text
    case Comment
    case Unknown
    case ProfileHeader
    case Notification
    case UserListItem

    static let all = [CommentHeader, Header, Footer, Image, Text, Comment, Unknown, ProfileHeader, Notification, UserListItem]

    var name: String {
        switch self {
        case CommentHeader: return "StreamHeaderCell"
        case Header: return "StreamHeaderCell"
        case Footer: return "StreamFooterCell"
        case Image: return "StreamImageCell"
        case Text: return "StreamTextCell"
        case Comment: return "StreamCommentCell"
        case Unknown: return "StreamUnknownCell"
        case ProfileHeader: return "ProfileHeaderCell"
        case Notification: return "NotificationCell"
        case UserListItem: return "UserListItemCell"
        }
    }

    var configure: CellConfigClosure {
        switch self {
        case CommentHeader: return StreamHeaderCellPresenter.configure
        case Header: return StreamHeaderCellPresenter.configure
        case Footer: return StreamFooterCellPresenter.configure
        case Image: return StreamImageCellPresenter.configure
        case Text: return StreamTextCellPresenter.configure
        case Comment: return ProfileHeaderCellPresenter.configure
        case ProfileHeader: return ProfileHeaderCellPresenter.configure
        case Notification: return NotificationCellPresenter.configure
        case Unknown: return ProfileHeaderCellPresenter.configure
        case UserListItem: return UserListItemCellPresenter.configure
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case CommentHeader: return StreamHeaderCell.self
        case Header: return StreamHeaderCell.self
        case Footer: return StreamFooterCell.self
        case Image: return StreamImageCell.self
        case Text: return StreamTextCell.self
        case Comment: return StreamCommentCell.self
        case ProfileHeader: return ProfileHeaderCell.self
        case Notification: return NotificationCell.self
        case Unknown: return UICollectionViewCell.self
        case UserListItem: return UserListItemCell.self
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        for type in all {
            if type == .Unknown || type == .Notification {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}
