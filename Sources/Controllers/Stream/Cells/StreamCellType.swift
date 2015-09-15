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

// MARK: Equatable
public func ==(lhs: StreamCellType, rhs: StreamCellType) -> Bool {
    return lhs.identifier == rhs.identifier
}

public enum StreamCellType: Equatable {
    case CommentHeader
    case CreateComment
    case Embed(data: Regionable?)
    case FollowAll(data: FollowAllCounts?)
    case Footer
    case Header
    case Image(data: Regionable?)
    case InviteFriends
    case Notification
    case OnboardingHeader(data: (String, String)?)
    case ProfileHeader
    case RepostHeader(height: CGFloat)
    case SeeMoreComments
    case Spacer(height: CGFloat)
    case StreamLoading
    case Text(data: Regionable?)
    case Toggle
    case Unknown
    case UserAvatars
    case UserListItem

    static let all = [
        CommentHeader,
        CreateComment,
        Embed(data: nil),
        FollowAll(data: nil),
        Footer,
        Header,
        Image(data: nil),
        InviteFriends,
        Notification,
        OnboardingHeader(data: nil),
        ProfileHeader,
        RepostHeader(height: 0.0),
        SeeMoreComments,
        Spacer(height: 0.0),
        StreamLoading,
        Text(data: nil),
        Toggle,
        Unknown,
        UserAvatars,
        UserListItem
    ]

    public var data: Any? {
        switch self {
        case let Embed(data): return data
        case let FollowAll(data): return data
        case let Image(data): return data
        case let OnboardingHeader(data): return data
        case let Text(data): return data
        default: return nil
        }
    }

    // this is just stupid...
    public var identifier: Int {
        switch self {
        case CommentHeader: return 0
        case CreateComment: return 1
        case Embed: return 2
        case FollowAll: return 3
        case Footer: return 4
        case Header: return 5
        case Image: return 6
        case InviteFriends: return 7
        case Notification: return 8
        case OnboardingHeader: return 9
        case ProfileHeader: return 10
        case RepostHeader: return 11
        case SeeMoreComments: return 12
        case Spacer: return 13
        case StreamLoading: return 14
        case Text: return 15
        case Toggle: return 16
        case Unknown: return 17
        case UserAvatars: return 18
        case UserListItem: return 19
        }
    }

    public var name: String {
        switch self {
        case CommentHeader, Header: return "StreamHeaderCell"
        case CreateComment: return "StreamCreateCommentCell"
        case Embed: return "StreamEmbedCell"
        case FollowAll: return FollowAllCell.reuseIdentifier()
        case Footer: return "StreamFooterCell"
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
        case CommentHeader, Header: return StreamHeaderCellPresenter.configure
        case CreateComment: return StreamCreateCommentCellPresenter.configure
        case Embed: return StreamEmbedCellPresenter.configure
        case FollowAll: return FollowAllCellPresenter.configure
        case Footer: return StreamFooterCellPresenter.configure
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
        case CommentHeader, Header: return StreamHeaderCell.self
        case CreateComment: return StreamCreateCommentCell.self
        case Embed: return StreamEmbedCell.self
        case FollowAll: return FollowAllCell.self
        case Footer: return StreamFooterCell.self
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

    public var oneColumnHeight: CGFloat {
        switch self {
        case CommentHeader,
             InviteFriends,
             SeeMoreComments:
            return 60.0
        case CreateComment,
             FollowAll:
            return 75.0
        case Footer:
            return 44.0
        case Header:
            return 90.0
        case Notification:
            return 117.0
        case OnboardingHeader:
            return 120.0
        case let RepostHeader(height):
            return height
        case let Spacer(height):
            return height
        case StreamLoading,
             UserAvatars:
            return 50.0
        case Toggle:
            return 40.0
        case UserListItem:
            return 85.0
        default: return 0.0
        }
    }

    public var multiColumnHeight: CGFloat {
        switch self {
        case CommentHeader,
             Header,
             InviteFriends,
             Notification,
             SeeMoreComments:
            return 60.0
        case CreateComment,
             FollowAll:
            return 75.0
        case Footer:
            return 44.0
        case OnboardingHeader:
            return 120.0
        case let RepostHeader(height):
            return height
        case let Spacer(height):
            return height
        case StreamLoading,
             UserAvatars:
            return 50.0
        case Toggle:
            return 40.0
        case UserListItem:
            return 85.0
        default:
            return 0.0
        }
    }

    public var isFullWidth: Bool {
        switch self {
        case CreateComment,
             FollowAll,
             InviteFriends,
             OnboardingHeader,
             ProfileHeader,
             SeeMoreComments,
             Spacer,
             StreamLoading,
             UserAvatars,
             UserListItem:
            return true
        case CommentHeader,
             Embed,
             Footer,
             Header,
             Image,
             Notification,
             RepostHeader,
             Text,
             Toggle,
             Unknown:
            return false
        }
    }

    public var collapsable: Bool {
        switch self {
        case Image, Text, Embed: return true
        default: return false
        }
    }

    static func registerAll(collectionView: UICollectionView) {
        let noNibTypes = [
            CreateComment,
            FollowAll(data: nil),
            Notification,
            OnboardingHeader(data: nil),
            Spacer(height: 0.0),
            StreamLoading,
            Unknown
        ]
        for type in all {
            if noNibTypes.indexOf(type) != nil {
                collectionView.registerClass(type.classType, forCellWithReuseIdentifier: type.name)
            } else {
                let nib = UINib(nibName: type.name, bundle: NSBundle(forClass: type.classType))
                collectionView.registerNib(nib, forCellWithReuseIdentifier: type.name)
            }
        }
    }
}
