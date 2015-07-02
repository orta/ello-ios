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
) -> Void

public enum StreamCellType {
    case CommentHeader
    case CreateComment
    case Embed
    case FollowAll
    case Footer
    case Header
    case Image
    case InviteFriends
    case Notification
    case OnboardingHeader
    case ProfileHeader
    case RepostHeader
    case SeeMoreComments
    case Spacer
    case StreamLoading
    case Text
    case Toggle
    case Unknown
    case UserAvatars
    case UserListItem

    static let all = [CommentHeader, CreateComment, Embed, FollowAll, Footer, Header, Image, InviteFriends, Notification, OnboardingHeader, ProfileHeader, RepostHeader, SeeMoreComments, Spacer, StreamLoading, Text, Toggle, Unknown, UserAvatars, UserListItem]

    public var name: String {
        switch self {
        case CommentHeader: return "StreamHeaderCell"
        case CreateComment: return "StreamCreateCommentCell"
        case Embed: return "StreamEmbedCell"
        case FollowAll: return FollowAllCell.reuseIdentifier()
        case Footer: return "StreamFooterCell"
        case Header: return "StreamHeaderCell"
        case Image: return "StreamImageCell"
        case InviteFriends: return "StreamInviteFriendsCell"
        case Notification: return "NotificationCell"
        case OnboardingHeader: return OnboardingHeaderCell.reuseIdentifier()
        case ProfileHeader: return "ProfileHeaderCell"
        case RepostHeader: return "StreamRepostHeaderCell"
        case SeeMoreComments: return "StreamSeeMoreCommentsCell"
        case Spacer: return "StreamSpacerCell"
        case StreamLoading: return "StreamLoadingCell"
        case Text: return "StreamTextCell"
        case Toggle: return "StreamToggleCell"
        case Unknown: return "StreamUnknownCell"
        case UserAvatars: return UserAvatarsCell.reuseIdentifier
        case UserListItem: return "UserListItemCell"
        }
    }

    public var selectable: Bool {
        switch self {
        case CreateComment, Header, InviteFriends, Notification, RepostHeader, SeeMoreComments, Toggle, UserListItem:
             return true
        default: return false
        }
    }

    public var configure: CellConfigClosure {
        switch self {
        case CommentHeader: return StreamHeaderCellPresenter.configure
        case CreateComment: return StreamCreateCommentCellPresenter.configure
        case Embed: return StreamEmbedCellPresenter.configure
        case FollowAll: return FollowAllCellPresenter.configure
        case Footer: return StreamFooterCellPresenter.configure
        case Header: return StreamHeaderCellPresenter.configure
        case Image: return StreamImageCellPresenter.configure
        case InviteFriends: return StreamInviteFriendsCellPresenter.configure
        case Notification: return NotificationCellPresenter.configure
        case OnboardingHeader: return OnboardingHeaderCellPresenter.configure
        case ProfileHeader: return ProfileHeaderCellPresenter.configure
        case RepostHeader: return StreamRepostHeaderCellPresenter.configure
        case Spacer: return { (cell, _, _, _, _) in cell.backgroundColor = .whiteColor() }
        case StreamLoading: return StreamLoadingCellPresenter.configure
        case Text: return StreamTextCellPresenter.configure
        case Toggle: return StreamToggleCellPresenter.configure
        case Unknown: return ProfileHeaderCellPresenter.configure
        case UserAvatars: return UserAvatarsCellPresenter.configure
        case UserListItem: return UserListItemCellPresenter.configure
        default: return { (_, _, _, _, _) in }
        }
    }

    public var classType: UICollectionViewCell.Type {
        switch self {
        case CommentHeader: return StreamHeaderCell.self
        case CreateComment: return StreamCreateCommentCell.self
        case Embed: return StreamEmbedCell.self
        case FollowAll: return FollowAllCell.self
        case Footer: return StreamFooterCell.self
        case Header: return StreamHeaderCell.self
        case Image: return StreamImageCell.self
        case InviteFriends: return StreamInviteFriendsCell.self
        case Notification: return NotificationCell.self
        case OnboardingHeader: return OnboardingHeaderCell.self
        case ProfileHeader: return ProfileHeaderCell.self
        case RepostHeader: return StreamRepostHeaderCell.self
        case SeeMoreComments: return StreamSeeMoreCommentsCell.self
        case StreamLoading: return StreamLoadingCell.self
        case Text: return StreamTextCell.self
        case Toggle: return StreamToggleCell.self
        case Unknown, Spacer: return UICollectionViewCell.self
        case UserAvatars: return UserAvatarsCell.self
        case UserListItem: return UserListItemCell.self
        }
    }

    public var collapsable: Bool {
        switch self {
        case Image, Text, Embed: return true
        default: return false
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        let noNibTypes: [StreamCellType] = [.CreateComment, .FollowAll, .Notification, .OnboardingHeader, .Spacer, .StreamLoading, .Unknown]
        for type in all {
            if find(noNibTypes, type) != nil {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}

