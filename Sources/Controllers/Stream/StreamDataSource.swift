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
    let testWebView:UIWebView
    let streamKind:StreamKind

    // these are assigned from the parent controller
    var sourceCellItems:[StreamCellItem] = []
    // these are either the same as sourceCellItems (no filter) or if a filter
    // is applied this stores the "visible" items
    var streamCellItems:[StreamCellItem] = []
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

    init(testWebView: UIWebView, streamKind:StreamKind) {
        self.streamKind = streamKind
        self.testWebView = testWebView
        self.textSizeCalculator = StreamTextCellSizeCalculator(webView: UIWebView(frame: testWebView.frame))
        self.notificationSizeCalculator = StreamNotificationCellSizeCalculator(webView: UIWebView(frame: testWebView.frame))
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

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            streamCellItems[indexPath.item].oneColumnCellHeight = height + imageBottomPadding
            streamCellItems[indexPath.item].multiColumnCellHeight = height + imageBottomPadding
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath, numberOfColumns:NSInteger) -> CGFloat {
        if numberOfColumns == 1 {
            return streamCellItems[indexPath.item].oneColumnCellHeight + imageBottomPadding ?? 0.0
        }
        else {
            return streamCellItems[indexPath.item].multiColumnCellHeight + imageBottomPadding ?? 0.0
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

            var cell = collectionView.dequeueReusableCellWithReuseIdentifier(streamCellItem.type.name, forIndexPath: indexPath) as UICollectionViewCell

            switch streamCellItem.type {
            case .Notification:
                (cell as NotificationCell).webLinkDelegate = webLinkDelegate
                (cell as NotificationCell).delegate = notificationDelegate
            case .Header, .CommentHeader:
                (cell as StreamHeaderCell).userDelegate = userDelegate
            case .Image:
                (cell as StreamImageCell).delegate = imageDelegate
            case .Text:
                (cell as StreamTextCell).webLinkDelegate = webLinkDelegate
            case .Footer:
                (cell as StreamFooterCell).delegate = postbarDelegate
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
    func addStreamCellItems(items:[StreamCellItem]) {
        self.sourceCellItems += items
        self.updateFilteredItems()
    }

    func addUnsizedCellItems(cellItems:[StreamCellItem], startingIndexPath:NSIndexPath?, completion:StreamContentReady) {
        let textElements = cellItems.filter {
            return $0.data as? TextRegion != nil
        }
        let notificationElements = cellItems.filter {
            return $0.type == .Notification
        }

        let afterBoth = Functional.after(2) {
            var indexPaths:[NSIndexPath] = []

            var indexPath:NSIndexPath = startingIndexPath ?? NSIndexPath(forItem: countElements(self.sourceCellItems) - 1, inSection: 0)

            for (index, cellItem) in enumerate(cellItems) {
                var index = indexPath.item + index + 1
                indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                self.sourceCellItems.insert(cellItem, atIndex: index)
            }

            self.updateFilteredItems()
            completion(indexPaths: indexPaths)
        }

        self.notificationSizeCalculator.processCells(notificationElements, afterBoth)
        self.textSizeCalculator.processCells(textElements, afterBoth)
    }

    private func updateFilteredItems() {
        if let streamFilter = streamFilter {
            self.streamCellItems = self.sourceCellItems.filter(streamFilter)
        }
        else {
            self.streamCellItems = self.sourceCellItems
        }
    }

}
