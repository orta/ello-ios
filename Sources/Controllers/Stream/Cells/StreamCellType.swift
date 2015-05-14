//
//  StreamCellType.swift
//  Ello
//
//  Created by Sean on 2/7/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias CellConfigClosure = (
    cell: UICollectionViewCell,
    streamCellItem: StreamCellItem,
    streamKind: StreamKind,
    indexPath: NSIndexPath,
    currentUser: User?
) -> ()

public enum StreamCellType {
    case CommentHeader
    case Header
    case Footer
    case Image
    case Text
    case Embed
    case RepostHeader
    case Unknown
    case ProfileHeader
    case Notification
    case UserListItem
    case CreateComment
    case StreamLoading
    case Toggle
    case SeeMoreComments
    case Spacer
    case OnboardingHeader

    static let all = [CommentHeader, Header, Footer, Image, Text, Embed, RepostHeader, Unknown, ProfileHeader, Notification, UserListItem, CreateComment, StreamLoading, Toggle, SeeMoreComments, Spacer, OnboardingHeader]

    public var name: String {
        switch self {
        case CommentHeader: return "StreamHeaderCell"
        case Header: return "StreamHeaderCell"
        case Footer: return "StreamFooterCell"
        case Image: return "StreamImageCell"
        case Text: return "StreamTextCell"
        case Embed: return "StreamEmbedCell"
        case RepostHeader: return "StreamRepostHeaderCell"
        case Unknown: return "StreamUnknownCell"
        case ProfileHeader: return "ProfileHeaderCell"
        case Notification: return "NotificationCell"
        case UserListItem: return "UserListItemCell"
        case CreateComment: return "StreamCreateCommentCell"
        case StreamLoading: return "StreamLoadingCell"
        case Toggle: return "StreamToggleCell"
        case SeeMoreComments: return "StreamSeeMoreCommentsCell"
        case Spacer: return "StreamSpacerCell"
        case OnboardingHeader: return OnboardingHeaderCell.reuseIdentifier()
        }
    }

    public var selectable: Bool {
        switch self {
        case .Header, .CreateComment, .Toggle, .UserListItem, .Notification, .SeeMoreComments:
             return true
        default: return false
        }
    }

    public var configure: CellConfigClosure {
        switch self {
        case CommentHeader: return StreamHeaderCellPresenter.configure
        case Header: return StreamHeaderCellPresenter.configure
        case Footer: return StreamFooterCellPresenter.configure
        case Image: return StreamImageCellPresenter.configure
        case Text: return StreamTextCellPresenter.configure
        case Embed: return StreamEmbedCellPresenter.configure
        case RepostHeader: return StreamRepostHeaderCellPresenter.configure
        case ProfileHeader: return ProfileHeaderCellPresenter.configure
        case Notification: return NotificationCellPresenter.configure
        case Unknown: return ProfileHeaderCellPresenter.configure
        case UserListItem: return UserListItemCellPresenter.configure
        case CreateComment: return StreamCreateCommentCellPresenter.configure
        case StreamLoading: return StreamLoadingCellPresenter.configure
        case Toggle: return StreamToggleCellPresenter.configure
        case Spacer: return { (cell, _, _, _, _) in cell.backgroundColor = .whiteColor() }
        case OnboardingHeader: return OnboardingHeaderCellPresenter.configure
        default: return { (_, _, _, _, _) in }
        }
    }

    public var classType: UICollectionViewCell.Type {
        switch self {
        case CommentHeader: return StreamHeaderCell.self
        case Header: return StreamHeaderCell.self
        case Footer: return StreamFooterCell.self
        case Image: return StreamImageCell.self
        case Text: return StreamTextCell.self
        case Embed: return StreamEmbedCell.self
        case RepostHeader: return StreamRepostHeaderCell.self
        case ProfileHeader: return ProfileHeaderCell.self
        case Notification: return NotificationCell.self
        case Unknown, Spacer: return UICollectionViewCell.self
        case UserListItem: return UserListItemCell.self
        case CreateComment: return StreamCreateCommentCell.self
        case StreamLoading: return StreamLoadingCell.self
        case Toggle: return StreamToggleCell.self
        case SeeMoreComments: return StreamSeeMoreCommentsCell.self
        case OnboardingHeader: return OnboardingHeaderCell.self
        }
    }

    public var collapsable: Bool {
        switch self {
        case Image, Text, Embed: return true
        default: return false
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        for type in all {
            if type == .Unknown || type == .Notification || type == .CreateComment || type == .StreamLoading || type == .Spacer || type == .OnboardingHeader {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}
