//
//  StreamDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebKit

public class StreamDataSource: NSObject, UICollectionViewDataSource {

    public typealias StreamContentReady = (indexPaths:[NSIndexPath]) -> ()
    public typealias StreamFilter = (StreamCellItem -> Bool)?

    let imageBottomPadding:CGFloat = 10.0
    public var streamKind:StreamKind
    var currentUser: User?

    // these are the items assigned from the parent controller
    public var streamCellItems:[StreamCellItem] = []

    // these are either the same as streamCellItems (no filter) or if a filter
    // is applied this stores the filtered items
    public var visibleCellItems:[StreamCellItem] = []

    // if a filter is added or removed, we update the items
    var streamFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    // if a filter is added or removed, we update the items
    public var streamCollapsedFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    public let textSizeCalculator:StreamTextCellSizeCalculator
    public let notificationSizeCalculator:StreamNotificationCellSizeCalculator
    public let profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator

    weak public var postbarDelegate:PostbarDelegate?
    weak public var notificationDelegate:NotificationDelegate?
    weak public var webLinkDelegate:WebLinkDelegate?
    weak public var imageDelegate:StreamImageCellDelegate?
    weak public var userDelegate:UserDelegate?
    weak public var relationshipDelegate: RelationshipDelegate?
    weak public var userListDelegate: UserListDelegate?

    public init(streamKind:StreamKind,
        textSizeCalculator: StreamTextCellSizeCalculator,
        notificationSizeCalculator: StreamNotificationCellSizeCalculator,
        profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator)
    {
        self.streamKind = streamKind
        self.textSizeCalculator = textSizeCalculator
        self.notificationSizeCalculator = notificationSizeCalculator
        self.profileHeaderSizeCalculator = profileHeaderSizeCalculator
        super.init()
    }

    // MARK: - Public

    public func removeAllCellItems() {
        streamCellItems = []
        updateFilteredItems()
    }

    public func removeCellItemsBelow(index: Int) {
        var belowIndex = index
        if index > streamCellItems.count {
            belowIndex = streamCellItems.count
        }
        let remainingCellItems = streamCellItems[0 ..< belowIndex]
        streamCellItems = Array(remainingCellItems)
        updateFilteredItems()
    }

    public func postForIndexPath(indexPath: NSIndexPath) -> Post? {
        return visibleStreamCellItem(at: indexPath)?.jsonable as? Post
    }

    public func commentForIndexPath(indexPath: NSIndexPath) -> Comment? {
        return visibleStreamCellItem(at: indexPath)?.jsonable as? Comment
    }

    public func visibleStreamCellItem(at indexPath: NSIndexPath) -> StreamCellItem? {
        if !isValidIndexPath(indexPath) { return nil }
        return visibleCellItems[indexPath.item]
    }

    public func cellItemsForPost(post:Post) -> [StreamCellItem] {
        return visibleCellItems.filter({ (item) -> Bool in
            if let cellPost = item.jsonable as? Post {
                return post.id == cellPost.id
            }
            else if let commentPost = item.jsonable as? Comment {
                return post.id == commentPost.postId
            }
            else {
                return false
            }
        })
    }

    public func userForIndexPath(indexPath: NSIndexPath) -> User? {
        if !isValidIndexPath(indexPath) { return nil }

        if let user = visibleCellItems[indexPath.item].jsonable as? User {
            return user
        }
        else if let authorable = visibleCellItems[indexPath.item].jsonable as? Authorable {
            return authorable.author
        }
        return nil
    }

    // this includes the `createComment` cell, since it contains a comment item
    public func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths:[NSIndexPath] = []
        for (index,value) in enumerate(visibleCellItems) {
            if let comment = value.jsonable as? Comment {
                if comment.postId == post.id {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
        }
        return indexPaths
    }

    public func footerIndexPathForPost(searchPost: Post) -> NSIndexPath? {
        for (index, value) in enumerate(visibleCellItems) {
            if value.type == .Footer,
               let post = value.jsonable as? Post {
                if searchPost.id == post.id {
                    return NSIndexPath(forItem: index, inSection: 0)
                }
            }
        }
        return nil
    }

    public func createCommentIndexPathForPost(post: Post) -> NSIndexPath? {
        let paths = commentIndexPathsForPost(post)
        if count(paths) > 0 {
            let path = paths[0]
            if let createCommentItem = visibleStreamCellItem(at: path) {
                if createCommentItem.type == .CreateComment {
                    return path
                }
            }
        }
        return nil
    }

    public func removeCommentsForPost(post: Post) -> [NSIndexPath] {
        let indexPaths = self.commentIndexPathsForPost(post)
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.commentIndexPathsForPost(post)
            var newItems = [StreamCellItem]()
            for (index, item) in enumerate(self.streamCellItems) {
                var remove = unfilteredIndexPaths.reduce(false) { remove, path in
                    return remove || path.item == index
                }
                if !remove {
                    newItems.append(item)
                }
            }
            self.streamCellItems = newItems
        }
        return indexPaths
    }

    public func removeItemAtIndexPath(indexPath: NSIndexPath) {
        let itemToRemove = self.visibleCellItems[indexPath.item]
        temporarilyUnfilter() {
            if let index = find(self.streamCellItems, itemToRemove) {
                self.streamCellItems.removeAtIndex(index)
            }
        }
    }

    public func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            if indexPath.item < count(visibleCellItems) {
                visibleCellItems[indexPath.item].oneColumnCellHeight = height + imageBottomPadding
                visibleCellItems[indexPath.item].multiColumnCellHeight = height + imageBottomPadding
            }
        }
    }

    public func heightForIndexPath(indexPath:NSIndexPath, numberOfColumns:NSInteger) -> CGFloat {
        if !isValidIndexPath(indexPath) { return 0 }

        // @seand: why does this always add padding? UserListItemCell is a fixed height, but this always adds an extra 10
        if numberOfColumns == 1 {
            return visibleCellItems[indexPath.item].oneColumnCellHeight + imageBottomPadding ?? 0.0
        }
        else {
            return visibleCellItems[indexPath.item].multiColumnCellHeight + imageBottomPadding ?? 0.0
        }
    }

    public func isFullWidthAtIndexPath(indexPath:NSIndexPath) -> Bool {
        if !isValidIndexPath(indexPath) { return true }

        return visibleCellItems[indexPath.item].isFullWidth
    }

    public func maintainAspectRatioForItemAtIndexPath(indexPath:NSIndexPath) -> Bool {
        return false
//        return visibleCellItems[indexPath.item].data?.kind == .Image ?? false
    }

    public func groupForIndexPath(indexPath:NSIndexPath) -> String {
        if !isValidIndexPath(indexPath) { return "0" }

        return (visibleCellItems[indexPath.item].jsonable as? Authorable)?.groupId ?? "0"
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellItems.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < count(visibleCellItems) {
            let streamCellItem = visibleCellItems[indexPath.item]

            var cell = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath) as! UICollectionViewCell

            switch streamCellItem.type {
            case .Notification:
                (cell as! NotificationCell).webLinkDelegate = webLinkDelegate
                (cell as! NotificationCell).delegate = notificationDelegate
            case .CreateComment:
                // (cell as! StreamCreateCommentCell)
                break
            case .Header, .CommentHeader:
                (cell as! StreamHeaderCell).postbarDelegate = postbarDelegate
                (cell as! StreamHeaderCell).userDelegate = userDelegate
            case .Image:
                (cell as! StreamImageCell).delegate = imageDelegate
            case .Text:
                (cell as! StreamTextCell).webLinkDelegate = webLinkDelegate
            case .Footer:
                (cell as! StreamFooterCell).delegate = postbarDelegate
            case .ProfileHeader:
                (cell as! ProfileHeaderCell).currentUser = currentUser
                (cell as! ProfileHeaderCell).relationshipView.relationshipDelegate = relationshipDelegate
                (cell as! ProfileHeaderCell).userListDelegate = userListDelegate
                (cell as! ProfileHeaderCell).webLinkDelegate = webLinkDelegate
            case .UserListItem:
                (cell as! UserListItemCell).relationshipView.relationshipDelegate = relationshipDelegate
                (cell as! UserListItemCell).userDelegate = userDelegate
                (cell as! UserListItemCell).currentUser = currentUser
            case .Toggle:
                // (cell as! StreamToggleCell)
                break
            default:
                break
            }

            streamCellItem.type.configure(
                cell: cell,
                streamCellItem: streamCellItem,
                streamKind: streamKind,
                indexPath: indexPath,
                currentUser: currentUser
            )

            return cell

        }
        return UICollectionViewCell()
    }

    // MARK: Adding items
    public func appendStreamCellItems(items: [StreamCellItem]) {
        self.streamCellItems += items
        self.updateFilteredItems()
    }

    public func appendUnsizedCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, completion: StreamContentReady) {
        let startingIndexPath = NSIndexPath(forItem: count(self.streamCellItems), inSection: 0)
        insertUnsizedCellItems(cellItems, withWidth: withWidth, startingIndexPath: startingIndexPath, completion: completion)
    }

    public func insertStreamCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath) -> [NSIndexPath] {
        // startingIndex represents the filtered index,
        // arrayIndex is the streamCellItems index
        let startingIndex = startingIndexPath.item
        var arrayIndex = startingIndexPath.item

        if let item = self.visibleStreamCellItem(at: startingIndexPath) {
            if let foundIndex = find(self.streamCellItems, item) {
                arrayIndex = foundIndex
            }
        }

        var indexPaths:[NSIndexPath] = []

        for (index, cellItem) in enumerate(cellItems) {
            indexPaths.append(NSIndexPath(forItem: startingIndex + index, inSection: startingIndexPath.section))
            self.streamCellItems.insert(cellItem, atIndex: arrayIndex + index)
        }

        self.updateFilteredItems()
        return indexPaths
    }

    public func insertUnsizedCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, startingIndexPath: NSIndexPath, completion: StreamContentReady) {
        self.calculateCellItems(cellItems, withWidth: withWidth) {
            let indexPaths = self.insertStreamCellItems(cellItems, startingIndexPath: startingIndexPath)
            completion(indexPaths: indexPaths)
        }
    }

    public func toggleCollapsedForIndexPath(indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath) {
            post.collapsed = !post.collapsed
            self.updateFilteredItems()
        }
    }

    private func calculateCellItems(cellItems:[StreamCellItem], withWidth: CGFloat, completion: ()->()) {
        let textElements = cellItems.filter {
            return $0.data as? TextRegion != nil
        }
        let notificationElements = cellItems.filter {
            return $0.type == StreamCellType.Notification
        }
        let profileHeaderItems = cellItems.filter {
            return $0.type == StreamCellType.ProfileHeader
        }
        let afterAll = Functional.after(3, block: completion)

        self.notificationSizeCalculator.processCells(notificationElements, withWidth: withWidth, completion: afterAll)
        self.textSizeCalculator.processCells(textElements, withWidth: withWidth, completion: afterAll)
        self.profileHeaderSizeCalculator.processCells(profileHeaderItems, withWidth: withWidth, completion: afterAll)
    }

    private func temporarilyUnfilter(block: ()->()) {
        let cachedStreamFilter = streamFilter
        let cachedStreamCollapsedFilter = streamCollapsedFilter
        self.streamFilter = nil
        self.streamCollapsedFilter = nil
        updateFilteredItems()

        block()

        self.streamFilter = cachedStreamFilter
        self.streamCollapsedFilter = cachedStreamCollapsedFilter
        updateFilteredItems()
    }

    private func updateFilteredItems() {
        if let streamFilter = streamFilter {
            self.visibleCellItems = self.streamCellItems.filter(streamFilter)
        }
        else {
            self.visibleCellItems = self.streamCellItems
        }

        if let streamCollapsedFilter = streamCollapsedFilter {
            self.visibleCellItems = self.visibleCellItems.filter(streamCollapsedFilter)
        }
    }

    private func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.item < count(visibleCellItems) && indexPath.section == 0
    }
}
