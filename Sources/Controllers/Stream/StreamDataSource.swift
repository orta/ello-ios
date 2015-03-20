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
    typealias StreamFilter = (StreamCellItem -> Bool)?

    let imageBottomPadding:CGFloat = 10.0
    var streamKind:StreamKind
    var currentUser: User?

    // these are the items assigned from the parent controller
    var streamCellItems:[StreamCellItem] = []
    // these are either the same as streamCellItems (no filter) or if a filter
    // is applied this stores the filtered items
    var visibleCellItems:[StreamCellItem] = []
    // if a filter is added or removed, we update the items
    var streamFilter: StreamFilter {
        didSet { updateFilteredItems() }
    }

    let textSizeCalculator:StreamTextCellSizeCalculator
    let notificationSizeCalculator:StreamNotificationCellSizeCalculator

    weak var postbarDelegate:PostbarDelegate?
    weak var notificationDelegate:NotificationDelegate?
    weak var webLinkDelegate:WebLinkDelegate?
    weak var imageDelegate:StreamImageCellDelegate?
    weak var userDelegate:UserDelegate?
    weak var relationshipDelegate: RelationshipDelegate?
    weak var userListDelegate: UserListDelegate?

    init(streamKind:StreamKind,
        textSizeCalculator: StreamTextCellSizeCalculator,
        notificationSizeCalculator: StreamNotificationCellSizeCalculator)
    {
        self.streamKind = streamKind
        self.textSizeCalculator = textSizeCalculator
        self.notificationSizeCalculator = notificationSizeCalculator
        super.init()
    }

    // MARK: - Public

    func removeAllCellItems() {
        streamCellItems = []
        updateFilteredItems()
    }

    func removeCellItemsBelow(index: Int) {
        var belowIndex = index
        if index > streamCellItems.count {
            belowIndex = streamCellItems.count
        }
        let remainingCellItems = streamCellItems[0 ..< belowIndex]
        streamCellItems = Array(remainingCellItems)
        updateFilteredItems()
    }

    func postForIndexPath(indexPath: NSIndexPath) -> Post? {
        if !isValidIndexPath(indexPath) { return nil }

        return visibleCellItems[indexPath.item].jsonable as? Post
    }

    func commentForIndexPath(indexPath: NSIndexPath) -> Comment? {
        if !isValidIndexPath(indexPath) { return nil }

        return visibleCellItems[indexPath.item].jsonable as? Comment
    }

    func streamCellItem(at indexPath: NSIndexPath) -> StreamCellItem? {
        return visibleCellItems[indexPath.item]
    }

    // TODO: also grab out comment cells for the detail view
    func cellItemsForPost(post:Post) -> [StreamCellItem] {
        return visibleCellItems.filter({ (item) -> Bool in
            if let cellPost = item.jsonable as? Post {
                return post.postId == cellPost.postId
            }
            else {
                return false
            }
        })
    }

    func userForIndexPath(indexPath: NSIndexPath) -> User? {
        if !isValidIndexPath(indexPath) { return nil }

        if let user = visibleCellItems[indexPath.item].jsonable as? User {
            return user
        }
        else if let authorable = visibleCellItems[indexPath.item].jsonable as? Authorable {
            return authorable.author
        }
        return nil
    }

    func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths:[NSIndexPath] = []

        for (index,value) in enumerate(visibleCellItems) {

            if let comment = value.jsonable as? Comment {
                if comment.parentPost?.postId == post.postId {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
        }
        return indexPaths
    }

    func removeCommentsForPost(post: Post) -> [NSIndexPath] {
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

    func removeItemAtIndexPath(indexPath: NSIndexPath) {
        if let itemToRemove = self.visibleCellItems[indexPath.item] {
            temporarilyUnfilter() {
                if let index = find(self.streamCellItems, itemToRemove) {
                    self.streamCellItems.removeAtIndex(index)
                }
            }
        }
    }

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            if indexPath.item < countElements(visibleCellItems) {
                visibleCellItems[indexPath.item].oneColumnCellHeight = height + imageBottomPadding
                visibleCellItems[indexPath.item].multiColumnCellHeight = height + imageBottomPadding
            }
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath, numberOfColumns:NSInteger) -> CGFloat {
        if !isValidIndexPath(indexPath) { return 0 }

        // @seand: why does this always add padding? UserListItemCell is a fixed height, but this always adds an extra 10
        if numberOfColumns == 1 {
            return visibleCellItems[indexPath.item].oneColumnCellHeight + imageBottomPadding ?? 0.0
        }
        else {
            return visibleCellItems[indexPath.item].multiColumnCellHeight + imageBottomPadding ?? 0.0
        }
    }

    func isFullWidthAtIndexPath(indexPath:NSIndexPath) -> Bool {
        if !isValidIndexPath(indexPath) { return true }

        return visibleCellItems[indexPath.item].isFullWidth
    }

    func maintainAspectRatioForItemAtIndexPath(indexPath:NSIndexPath) -> Bool {
        return false
//        return visibleCellItems[indexPath.item].data?.kind == .Image ?? false
    }

    func groupForIndexPath(indexPath:NSIndexPath) -> String {
        if !isValidIndexPath(indexPath) { return "0" }

        return (visibleCellItems[indexPath.item].jsonable as? Authorable)?.groupId ?? "0"
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellItems.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < countElements(visibleCellItems) {
            let streamCellItem = visibleCellItems[indexPath.item]

            var cell = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath) as UICollectionViewCell

            switch streamCellItem.type {
            case .Notification:
                (cell as NotificationCell).webLinkDelegate = webLinkDelegate
                (cell as NotificationCell).delegate = notificationDelegate
            case .CreateComment:
                // (cell as StreamCreateCommentCell)
                break
            case .Header, .CommentHeader:
                (cell as StreamHeaderCell).postbarDelegate = postbarDelegate
                (cell as StreamHeaderCell).userDelegate = userDelegate
            case .Image:
                (cell as StreamImageCell).delegate = imageDelegate
            case .Text:
                (cell as StreamTextCell).webLinkDelegate = webLinkDelegate
            case .Footer:
                (cell as StreamFooterCell).delegate = postbarDelegate
            case .ProfileHeader:
                (cell as ProfileHeaderCell).relationshipView.relationshipDelegate = relationshipDelegate
                (cell as ProfileHeaderCell).userListDelegate = userListDelegate
                (cell as ProfileHeaderCell).currentUser = currentUser
            case .UserListItem:
                (cell as UserListItemCell).relationshipView.relationshipDelegate = relationshipDelegate
                (cell as UserListItemCell).userDelegate = userDelegate
                (cell as UserListItemCell).currentUser = currentUser
            default:
                break
            }

            streamCellItem.type.configure(
                cell: cell,
                streamCellItem: streamCellItem,
                streamKind: streamKind,
                indexPath: indexPath
            )

            return cell

        }
        return UICollectionViewCell()
    }

    // MARK: Adding items
    func appendStreamCellItems(items: [StreamCellItem]) {
        self.streamCellItems += items
        self.updateFilteredItems()
    }

    func appendUnsizedCellItems(cellItems: [StreamCellItem], completion: StreamContentReady) {
        let startingIndexPath = NSIndexPath(forItem: countElements(self.streamCellItems), inSection: 0)
        insertUnsizedCellItems(cellItems, startingIndexPath: startingIndexPath, completion: completion)
    }

    func insertUnsizedCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath, completion: StreamContentReady) {
        self.calculateCellItems(cellItems) {
            var indexPaths:[NSIndexPath] = []

            var startingIndex:Int = startingIndexPath.item

            for (index, cellItem) in enumerate(cellItems) {
                var index = startingIndex + index
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                self.streamCellItems.insert(cellItem, atIndex: index)
            }

            self.updateFilteredItems()
            completion(indexPaths: indexPaths)
        }
    }

    private func calculateCellItems(cellItems:[StreamCellItem], completion: ()->()) {
        let textElements = cellItems.filter {
            return $0.data as? TextRegion != nil
        }
        let notificationElements = cellItems.filter {
            return $0.type == .Notification
        }

        let afterBoth = Functional.after(2, completion)

        self.notificationSizeCalculator.processCells(notificationElements, afterBoth)
        self.textSizeCalculator.processCells(textElements, afterBoth)
    }

    private func temporarilyUnfilter(block: ()->()) {
        if let cachedStreamFilter = streamFilter {
            self.streamFilter = nil
            block()
            self.streamFilter = cachedStreamFilter
        }
        else {
            block()
            updateFilteredItems()
        }
    }

    private func updateFilteredItems() {
        if let streamFilter = streamFilter {
            self.visibleCellItems = self.streamCellItems.filter(streamFilter)
        }
        else {
            self.visibleCellItems = self.streamCellItems
        }
    }

    private func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.item < countElements(visibleCellItems) && indexPath.section == 0
    }
}
