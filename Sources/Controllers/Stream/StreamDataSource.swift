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

    public typealias StreamContentReady = (indexPaths:[NSIndexPath]) -> Void
    public typealias StreamFilter = (StreamCellItem -> Bool)?

    let imageBottomPadding:CGFloat = 10.0
    public var streamKind:StreamKind
    public var currentUser: User?

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
    public let imageSizeCalculator: StreamImageCellSizeCalculator

    weak public var postbarDelegate:PostbarDelegate?
    weak public var notificationDelegate:NotificationDelegate?
    weak public var webLinkDelegate:WebLinkDelegate?
    weak public var imageDelegate:StreamImageCellDelegate?
    weak public var userDelegate:UserDelegate?
    weak public var relationshipDelegate: RelationshipDelegate?
    weak public var userListDelegate: UserListDelegate?

    public init(
        streamKind:StreamKind,
        textSizeCalculator: StreamTextCellSizeCalculator,
        notificationSizeCalculator: StreamNotificationCellSizeCalculator,
        profileHeaderSizeCalculator: ProfileHeaderCellSizeCalculator,
        imageSizeCalculator: StreamImageCellSizeCalculator)
    {
        self.streamKind = streamKind
        self.textSizeCalculator = textSizeCalculator
        self.notificationSizeCalculator = notificationSizeCalculator
        self.profileHeaderSizeCalculator = profileHeaderSizeCalculator
        self.imageSizeCalculator = imageSizeCalculator
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

    public func userForIndexPath(indexPath: NSIndexPath) -> User? {
        let item = visibleStreamCellItem(at: indexPath)

        if let authorable = item?.jsonable as? Authorable {
            return authorable.author
        }
        return item?.jsonable as? User
    }

    public func postForIndexPath(indexPath: NSIndexPath) -> Post? {
        let item = visibleStreamCellItem(at: indexPath)

        if let notification = item?.jsonable as? Notification {
            if let comment = notification.activity.subject as? Comment {
                return comment.parentPost
            }
            return notification.activity.subject as? Post
        }
        return item?.jsonable as? Post
    }

    public func imageAssetForIndexPath(indexPath: NSIndexPath) -> Asset? {
        let item = visibleStreamCellItem(at: indexPath)
        let region = item?.region as? ImageRegion
        return region?.asset
    }

    public func commentForIndexPath(indexPath: NSIndexPath) -> Comment? {
        let item = visibleStreamCellItem(at: indexPath)
        return item?.jsonable as? Comment
    }

    public func visibleStreamCellItem(at indexPath: NSIndexPath) -> StreamCellItem? {
        if !isValidIndexPath(indexPath) { return nil }
        return visibleCellItems.safeValue(indexPath.item)
    }

    public func cellItemsForPost(post:Post) -> [StreamCellItem] {
        var tmp = [StreamCellItem]()
        temporarilyUnfilter {
            tmp = self.visibleCellItems.reduce([]) { arr, item in
                if let cellPost = item.jsonable as? Post where post.id == cellPost.id {
                    return arr + [item]
                }
                return arr
            }
        }
        return tmp
    }

    // this includes the `createComment` cell, `spacer` cell, and `seeMoreComments` cell since they contain a comment item
    public func commentIndexPathsForPost(post: Post) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for (index, value) in enumerate(visibleCellItems) {
            if let comment = value.jsonable as? Comment where comment.loadedFromPostId == post.id {
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
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
                (cell as! NotificationCell).userDelegate = userDelegate
                (cell as! NotificationCell).delegate = notificationDelegate
            case .CreateComment:
                // (cell as! StreamCreateCommentCell)
                break
            case .Header, .CommentHeader:
                (cell as! StreamHeaderCell).postbarDelegate = postbarDelegate
                (cell as! StreamHeaderCell).userDelegate = userDelegate
            case .Image:
                (cell as! StreamImageCell).streamImageCellDelegate = imageDelegate
            case .Text:
                (cell as! StreamTextCell).webLinkDelegate = webLinkDelegate
            case .Footer:
                (cell as! StreamFooterCell).delegate = postbarDelegate
            case .ProfileHeader:
                (cell as! ProfileHeaderCell).currentUser = currentUser
                (cell as! ProfileHeaderCell).relationshipControl.relationshipDelegate = relationshipDelegate
                (cell as! ProfileHeaderCell).userListDelegate = userListDelegate
                (cell as! ProfileHeaderCell).webLinkDelegate = webLinkDelegate
            case .UserListItem:
                (cell as! UserListItemCell).relationshipControl.relationshipDelegate = relationshipDelegate
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

    public func modifyItems(jsonable: JSONAble, change: ContentChange, collectionView: UICollectionView) {
        // get items that match id and type -> [IndexPath]
        // based on change decide to update/remove those items
        switch change {
        case .Create:
            var indexPath: NSIndexPath?
            // if comment, add new comment cells
            if  let comment = jsonable as? Comment,
                let parentPost = comment.parentPost
            {
                let indexPaths = self.commentIndexPathsForPost(parentPost)
                if let first = indexPaths.first {
                    if self.visibleCellItems[first.item].type == .CreateComment {
                        indexPath = NSIndexPath(forItem: first.item + 1, inSection: first.section)
                    }
                }
            }

            // else if post, add new post cells
            else if let post = jsonable as? Post {
                switch streamKind {
                case .Friend: indexPath = NSIndexPath(forItem: 0, inSection: 0)
                case let .Profile: indexPath = NSIndexPath(forItem: 1, inSection: 0)
                case let .UserStream(userParam):
                    if currentUser?.id == userParam {
                        indexPath = NSIndexPath(forItem: 1, inSection: 0)
                    }
                default: break
                }
            }

            // else if love, add post to loves
            else if let love = jsonable as? Love {
                switch streamKind {
                case .Loves: indexPath = NSIndexPath(forItem: 0, inSection: 0)
                default: break
                }
            }

            if let indexPath = indexPath {
                self.insertUnsizedCellItems(
                    StreamCellItemParser().parse([jsonable], streamKind: self.streamKind),
                    withWidth: UIScreen.screenWidth(),
                    startingIndexPath: indexPath)
                    { newIndexPaths in
                        collectionView.insertItemsAtIndexPaths(newIndexPaths)
                    }
            }


        case .Delete:
            collectionView.deleteItemsAtIndexPaths(removeItemsForJSONAble(jsonable, change: change))
        case .Update:
            var shouldReload = true
            switch streamKind {
            case .Loves:
                if let post = jsonable as? Post where !post.loved {
                    // the post was unloved
                    collectionView.deleteItemsAtIndexPaths(removeItemsForJSONAble(jsonable, change: .Delete))
                    shouldReload = false
                }
            default: shouldReload = true
            }
            if shouldReload {
                let (indexPaths, items) = elementsForJSONAble(jsonable, change: change)
                items.map { $0.jsonable = jsonable }
                collectionView.reloadItemsAtIndexPaths(indexPaths)
            }
        default: break
        }
    }

    public func modifyUserRelationshipItems(user: User, collectionView: UICollectionView) {
        switch user.relationshipPriority {
        case .Friend, .Noise, .Inactive:
            var changedItems = elementsForJSONAble(user, change: .Update)
            for item in changedItems.1 {
                if let oldUser = item.jsonable as? User {
                    // relationship changes
                    oldUser.relationshipPriority = user.relationshipPriority
                    oldUser.followersCount = user.followersCount
                    oldUser.followingCount = user.followingCount
                }
            }
            collectionView.reloadItemsAtIndexPaths(changedItems.0)
        case .Block, .Mute:
            collectionView.deleteItemsAtIndexPaths(removeItemsForJSONAble(user, change: .Delete))
        default: break
        }
    }

    public func modifyUserSettingsItems(user: User, collectionView: UICollectionView) {
        var changedItems = elementsForJSONAble(user, change: .Update)
        for item in changedItems.1 {
            if let oldUser = item.jsonable as? User {
                item.jsonable = user
            }
        }
        collectionView.reloadItemsAtIndexPaths(changedItems.0)
    }

    public func removeItemsForJSONAble(jsonable: JSONAble, change: ContentChange) -> [NSIndexPath] {
        let indexPaths = self.elementsForJSONAble(jsonable, change: change).0
        temporarilyUnfilter() {
            // these paths might be different depending on the filter
            let unfilteredIndexPaths = self.elementsForJSONAble(jsonable, change: change).0
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

    private func elementsForJSONAble(jsonable: JSONAble, change: ContentChange) -> ([NSIndexPath], [StreamCellItem]) {
        var indexPaths = [NSIndexPath]()
        var items = [StreamCellItem]()
        if let comment = jsonable as? Comment {
            for (index, item) in enumerate(visibleCellItems) {
                if let itemComment = item.jsonable as? Comment where comment.id == itemComment.id {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    items.append(item)
                }
            }
        }
        else if let post = jsonable as? Post {
            for (index, item) in enumerate(visibleCellItems) {
                if let itemPost = item.jsonable as? Post where post.id == itemPost.id {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    items.append(item)
                }
                else if change == .Delete {
                    if let itemComment = item.jsonable as? Comment where itemComment.postId == post.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                }
            }
        }
        else if let user = jsonable as? User {
            for (index, item) in enumerate(visibleCellItems) {
                switch user.relationshipPriority {
                case .Block:
                    if let itemUser = item.jsonable as? User where user.id == itemUser.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                    else if let itemComment = item.jsonable as? Comment {
                        if  user.id == itemComment.authorId ||
                            user.id == itemComment.parentPost?.authorId
                        {
                            indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                            items.append(item)
                        }
                    }
                    else if let itemPost = item.jsonable as? Post where user.id == itemPost.authorId {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                case .Mute:
                    if streamKind.name == StreamKind.Notifications.name {
                        if let itemNotification = item.jsonable as? Notification where user.id == itemNotification.author?.id {
                            indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                            items.append(item)
                        }
                    }
                default:
                    if let itemUser = item.jsonable as? User where user.id == itemUser.id {
                        indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                        items.append(item)
                    }
                }
            }
        }
        return (indexPaths, items)
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
        else if arrayIndex == count(visibleCellItems) {
            arrayIndex = count(streamCellItems)
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
            let cellItem = self.visibleStreamCellItem(at: indexPath)
            let newState: StreamCellState = cellItem?.state == .Expanded ? .Collapsed : .Expanded
            let cellItems = self.cellItemsForPost(post)
            for item in cellItems {
                // don't toggle the footer's state, it is used by comment open/closed
                if item.type != .Footer {
                    item.state = newState
                }
            }
            self.updateFilteredItems()
        }
    }

    private func calculateCellItems(cellItems:[StreamCellItem], withWidth: CGFloat, completion: ElloEmptyCompletion) {
        let textCells = filterTextCells(cellItems)
        let imageCells = filterImageCells(cellItems)
        let notificationElements = cellItems.filter {
            return $0.type == StreamCellType.Notification
        }
        let profileHeaderItems = cellItems.filter {
            return $0.type == StreamCellType.ProfileHeader
        }
        let afterAll = after(4, completion)

        self.imageSizeCalculator.processCells(imageCells.normal, withWidth: withWidth) {
            self.imageSizeCalculator.processCells(imageCells.repost, withWidth: withWidth - 30.0, completion: afterAll)
        }
        // -30.0 acounts for the 15 on either side for constraints
        let textLeftRightConstraintWidth = (StreamTextCellPresenter.postMargin * 2)
        self.textSizeCalculator.processCells(textCells.normal, withWidth: withWidth - textLeftRightConstraintWidth) {
            // extra -30.0 acounts for the left indent on a repost with the black line
            self.textSizeCalculator.processCells(textCells.repost, withWidth: withWidth - (textLeftRightConstraintWidth * 2), completion: afterAll)
        }
        self.notificationSizeCalculator.processCells(notificationElements, withWidth: withWidth, completion: afterAll)
        self.profileHeaderSizeCalculator.processCells(profileHeaderItems, withWidth: withWidth, completion: afterAll)
    }

    private func filterTextCells(cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
        var cells = [StreamCellItem]()
        var repostCells = [StreamCellItem]()
        for item in cellItems {
            if let textRegion = item.data as? TextRegion {
                if textRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
        }
        return (cells, repostCells)
    }

    private func filterImageCells(cellItems: [StreamCellItem]) -> (normal: [StreamCellItem], repost: [StreamCellItem]) {
        var cells = [StreamCellItem]()
        var repostCells = [StreamCellItem]()
        for item in cellItems {
            if let imageRegion = item.data as? ImageRegion {
                if imageRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
            else if let embedRegion = item.data as? EmbedRegion {
                if embedRegion.isRepost {
                    repostCells.append(item)
                }
                else {
                    cells.append(item)
                }
            }
        }
        return (cells, repostCells)
    }

    private func temporarilyUnfilter(@noescape block: ElloEmptyCompletion) {
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
        self.visibleCellItems = self.streamCellItems

        if let streamFilter = streamFilter {
            self.visibleCellItems = self.visibleCellItems.filter { item in
                return item.alwaysShow() || streamFilter(item)
            }
        }

        if let streamCollapsedFilter = streamCollapsedFilter {
            self.visibleCellItems = self.visibleCellItems.filter { item in
                return item.alwaysShow() || streamCollapsedFilter(item)
            }
        }
    }

    private func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.item < count(visibleCellItems) && indexPath.section == 0
    }
}
