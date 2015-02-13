//
//  StreamCellType.swift
//  Ello
//
//  Created by Sean on 2/7/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

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

    static let all = [CommentHeader, Header, Footer, Image, Text, Comment, Unknown, ProfileHeader, Notification]

    var name: String {
        switch self {
        case CommentHeader: return "StreamCommentHeaderCell"
        case Header: return "StreamHeaderCell"
        case Footer: return "StreamFooterCell"
        case Image: return "StreamImageCell"
        case Text: return "StreamTextCell"
        case Comment: return "StreamCommentCell"
        case Unknown: return "StreamUnknownCell"
        case ProfileHeader: return "ProfileHeaderCell"
        case Notification: return "NotificationCell"
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case CommentHeader: return StreamCommentHeaderCell.self
        case Header: return StreamHeaderCell.self
        case Footer: return StreamFooterCell.self
        case Image: return StreamImageCell.self
        case Text: return StreamTextCell.self
        case Comment: return StreamCommentCell.self
        case Unknown: return UICollectionViewCell.self
        case ProfileHeader: return ProfileHeaderCell.self
        case Notification: return UICollectionViewCell.self
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        for type in all {
            if type == self.Unknown || type == self.Notification {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}
