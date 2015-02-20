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

    let imageBottomPadding:CGFloat = 10.0
    let testWebView:UIWebView
    var streamKind:StreamKind

    var indexFile:String?
    var streamCellItems:[StreamCellItem] = []
    let sizeCalculator:StreamTextCellSizeCalculator
    weak var postbarDelegate:PostbarDelegate?
    weak var webLinkDelegate:WebLinkDelegate?
    weak var imageDelegate:StreamImageCellDelegate?
    weak var userDelegate:UserDelegate?
    weak var relationshipDelegate: RelationshipDelegate?

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
            case .Header, .CommentHeader:
                (cell as StreamHeaderCell).userDelegate = userDelegate
            case .Image:
                (cell as StreamImageCell).delegate = imageDelegate
            case .Text:
                (cell as StreamTextCell).webLinkDelegate = webLinkDelegate
            case .Footer:
                (cell as StreamFooterCell).delegate = postbarDelegate
            case .ProfileHeader:
                (cell as ProfileHeaderCell).relationshipView.relationshipDelegate = relationshipDelegate
            default:
                println("nothing to see here")
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

    // MARK: - Private
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
