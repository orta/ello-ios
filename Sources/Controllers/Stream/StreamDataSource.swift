//
//  StreamDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebKit

class StreamDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamContentReady = (indexPaths:[NSIndexPath]) -> ()

    let testWebView:UIWebView
    let streamKind:StreamKind

    var indexFile:String?
    var streamCellItems:[StreamCellItem] = []
    let sizeCalculator:StreamTextCellSizeCalculator
    weak var postbarDelegate:PostbarDelegate?
    weak var webLinkDelegate:WebLinkDelegate?
    weak var imageDelegate:StreamImageCellDelegate?
    weak var userDelegate:UserDelegate?

    init(testWebView: UIWebView, streamKind:StreamKind) {
        self.streamKind = streamKind
        self.testWebView = testWebView
        self.sizeCalculator = StreamTextCellSizeCalculator(webView: testWebView)
        super.init()
    }

    // MARK: - Public

    func postForIndexPath(indexPath:NSIndexPath) -> Post? {
        if indexPath.item >= streamCellItems.count {
            return nil
        }
        return streamCellItems[indexPath.item].jsonable as? Post
    }

    // TODO: also grab out comment cells for the detail view
    func cellItemsForPost(post:Post) -> [StreamCellItem] {
        return streamCellItems.filter({ (item) -> Bool in
            if let cellPost = item.jsonable as? Post {
                return post.postId == cellPost.postId
            }
            else {
                return false
            }
        })
    }

    func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths:[NSIndexPath] = []

        for (index,value) in enumerate(streamCellItems) {

            if let comment = value.jsonable as? Comment {
                if comment.parentPost?.postId == post.postId {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
        }
        return indexPaths
    }

    func addStreamCellItems(items:[StreamCellItem]) {
        self.streamCellItems += items
    }

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            streamCellItems[indexPath.item].oneColumnCellHeight = height
            streamCellItems[indexPath.item].multiColumnCellHeight = height
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath, numberOfColumns:NSInteger) -> CGFloat {
        if numberOfColumns == 1 {
            return streamCellItems[indexPath.item].oneColumnCellHeight ?? 0.0
        }
        else {
            return streamCellItems[indexPath.item].multiColumnCellHeight ?? 0.0
        }
    }

    func isFullWidthAtIndexPath(indexPath:NSIndexPath) -> Bool {
        return streamCellItems[indexPath.item].isFullWidth
    }

    func maintainAspectRatioForItemAtIndexPath(indexPath:NSIndexPath) -> Bool {
        return false
//        return streamCellItems[indexPath.item].data?.kind == .Image ?? false
    }

    func groupForIndexPath(indexPath:NSIndexPath) -> String {
        return (streamCellItems[indexPath.item].jsonable as? Authorable)?.groupId ?? "0"
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamCellItems.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < countElements(streamCellItems) {
            let streamCellItem = streamCellItems[indexPath.item]

            switch streamCellItem.type {
            case .Header, .CommentHeader:
                return headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Image:
                return imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Text:
                return textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Footer:
                return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Notification:
                return notificationCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .ProfileHeader:
                return profileHeaderCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            default:
                return UICollectionViewCell()
            }
        }
        return UICollectionViewCell()
    }

    // MARK: - Private

    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        var headerCell: StreamHeaderCell = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath) as StreamHeaderCell
        if streamCellItem.type == .Header {
            headerCell.streamKind = streamKind
        }

        if let avatarURL = (streamCellItem.jsonable as Authorable).author?.avatarURL? {
            headerCell.setAvatarURL(avatarURL)
        }

        headerCell.timestampLabel.text = NSDate().distanceOfTimeInWords((streamCellItem.jsonable as Authorable).createdAt)
        headerCell.usernameLabel.text = ((streamCellItem.jsonable as Authorable).author?.atName ?? "@meow")
        headerCell.userDelegate = userDelegate
        return headerCell
    }

    private func imageCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamImageCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamCellType.Image.name, forIndexPath: indexPath) as StreamImageCell

        if let photoData = streamCellItem.data as ImageRegion? {
            if let photoURL = photoData.asset?.hdpi?.url? {
                imageCell.serverProvidedAspectRatio = StreamCellItemParser.aspectRatioForImageBlock(photoData)
                imageCell.setImageURL(photoURL)
            }
            else if let photoURL = photoData.url? {
                imageCell.setImageURL(photoURL)
            }
        }

        imageCell.delegate = imageDelegate
        return imageCell
    }

    private func textCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamTextCell {
        var textCell:StreamTextCell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamCellType.Text.name, forIndexPath: indexPath) as StreamTextCell

        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as TextRegion? {
            textCell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }

        if let comment = streamCellItem.jsonable as? Comment {
            textCell.leadingConstraint.constant = 58.0
        }
        else {
            textCell.leadingConstraint.constant = 0.0
        }

        textCell.webLinkDelegate = webLinkDelegate
        return textCell
    }

    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamCellType.Footer.name, forIndexPath: indexPath) as StreamFooterCell
        if let post = streamCellItem.jsonable as? Post {
            footerCell.comments = post.commentsCount?.localizedStringFromNumber()
            if self.streamKind.isGridLayout {
                footerCell.views = ""
                footerCell.reposts = ""
            }
            else {
                footerCell.views = post.viewsCount?.localizedStringFromNumber()
                footerCell.reposts = post.repostsCount?.localizedStringFromNumber()
            }
            footerCell.streamKind = streamKind
            footerCell.delegate = postbarDelegate
        }

        return footerCell
    }

    private func notificationCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> NotificationCell {
        let notificationCell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamCellType.Notification.name, forIndexPath: indexPath) as NotificationCell
        var activity = streamCellItem.jsonable as Activity

        switch activity.kind {
        case .RepostNotification:
            return repostNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .NewFollowedUserPost:
            return newFollowedUserNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .NewFollowerPost:
            return newFollowerNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .PostMentionNotification:
            return postMentionNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .CommentMentionNotification:
            return commentMentionNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .InvitationAcceptedPost:
            return invitationAcceptedNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .CommentNotification:
            return commentNotificationCell(streamCellItem, notificationCell: notificationCell)
        case .WelcomeNotification:
            return welcomeNotificationCell(streamCellItem, notificationCell: notificationCell)
        default:
            return notificationCell
        }
    }

    func profileHeaderCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> ProfileHeaderCell {
        let profileHeader = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath) as ProfileHeaderCell
        let user = streamCellItem.jsonable as User

        if let avatarURL = user.avatarURL? {
            profileHeader.setAvatarURL(avatarURL)
        }

        profileHeader.usernameLabel.text = user.atName
        profileHeader.nameLabel.text = user.name

        return profileHeader
    }

    func addUnsizedCellItems(cellItems:[StreamCellItem], startingIndexPath:NSIndexPath?, completion:StreamContentReady) {
        let textElements = cellItems.filter {
            return $0.data as? TextRegion != nil
        }

        self.sizeCalculator.processCells(textElements) {
            var indexPaths:[NSIndexPath] = []

            var indexPath:NSIndexPath = startingIndexPath ?? NSIndexPath(forItem: countElements(self.streamCellItems) - 1, inSection: 0)

            for (index, cellItem) in enumerate(cellItems) {
                var index = indexPath.item + index + 1
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                self.streamCellItems.insert(cellItem, atIndex: index)
            }

            completion(indexPaths: indexPaths)
        }
   }
}


extension StreamDataSource {
    private func repostNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var post = activity.subject as Post

        notificationCell.title = NSAttributedString(string: "\(post.author!.atName) reposted your post.")
        notificationCell.image = nil
        notificationCell.messageHtml = "<b>HOPE</b> this <i>works</i>!"
        notificationCell.avatarURL = post.author?.avatarURL

        return notificationCell
    }

    private func newFollowedUserNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var user = activity.subject as User

        notificationCell.title = NSAttributedString(string: "Your started following \(user.atName).")
        notificationCell.image = nil
        notificationCell.messageHtml = nil
        notificationCell.avatarURL = user.avatarURL

        return notificationCell
    }

    private func newFollowerNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var user = activity.subject as User

        notificationCell.title = NSAttributedString(string: "\(user.atName) started following you.")
        notificationCell.image = nil
        notificationCell.messageHtml = nil
        notificationCell.avatarURL = user.avatarURL

        return notificationCell
    }

    private func postMentionNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var post = activity.subject as Post

        notificationCell.title = NSAttributedString(string: "\(post.author!.atName) mentioned you in a post.")
        notificationCell.image = nil
        notificationCell.messageHtml = ""
        notificationCell.avatarURL = post.author?.avatarURL

        return notificationCell
    }

    private func commentMentionNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var comment = activity.subject as Comment

        notificationCell.title = NSAttributedString(string: "\(comment.author!.atName) mentioned you in a comment.")
        notificationCell.image = nil
        notificationCell.messageHtml = ""
        notificationCell.avatarURL = comment.author?.avatarURL

        return notificationCell
    }

    private func invitationAcceptedNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var user = activity.subject as User

        notificationCell.title = NSAttributedString(string: "\(user.atName) accepted your invitation.")
        notificationCell.image = nil
        notificationCell.messageHtml = nil
        notificationCell.avatarURL = user.avatarURL

        return notificationCell
    }

    private func commentNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var comment = activity.subject as Comment

        notificationCell.title = NSAttributedString(string: "\(comment.author!.atName) commented on your post.")
        notificationCell.image = nil
        notificationCell.messageHtml = ""
        notificationCell.avatarURL = comment.author?.avatarURL

        return notificationCell
    }

    private func welcomeNotificationCell(streamCellItem:StreamCellItem, notificationCell: NotificationCell) -> NotificationCell {
        var activity = streamCellItem.jsonable as Activity
        var user = activity.subject as User

        notificationCell.title = NSAttributedString(string: "Welcome to Ello!")
        notificationCell.image = nil
        notificationCell.messageHtml = nil
        notificationCell.avatarURL = user.avatarURL

        return notificationCell
    }
}
