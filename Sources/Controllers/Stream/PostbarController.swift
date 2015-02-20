//
//  PostbarController.swift
//  Ello
//
//  Created by Sean on 1/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class PostbarController: NSObject, PostbarDelegate {

    let presentingController: StreamViewController?
    let collectionView: UICollectionView
    let dataSource: StreamDataSource

    init(collectionView: UICollectionView, dataSource: StreamDataSource, presentingController: StreamViewController?) {
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.collectionView.dataSource = dataSource
        self.presentingController = presentingController
    }

    // MARK:

    func viewsButtonTapped(cell:StreamFooterCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let items = self.dataSource.cellItemsForPost(post)
                presentingController?.postTappedDelegate?.postTapped(post, initialItems: items)
            }
        }
    }

    func commentsButtonTapped(cell:StreamFooterCell, commentsButton: CommentButton) {
        cell.commentsButton.enabled = false
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                if cell.commentsOpened {
                    let indexPaths = self.dataSource.commentIndexPathsForPost(post)
                    if let first = indexPaths.first {
                        let range = Range(start: first.item,  end: first.item + countElements(indexPaths))
                        self.dataSource.streamCellItems.removeRange(range)
                        self.collectionView.deleteItemsAtIndexPaths(indexPaths)
                    }
                    cell.commentsButton.enabled = true
                }
                else {
                    let streamService = StreamService()
                    streamService.loadMoreCommentsForPost(post.postId, success: {
                        commentsButton.finishAnimation()
                        self.commentLoadSuccess($0, indexPath: indexPath, cell: cell)
                    }, failure: { (error, statusCode) -> () in
                        println("comment load failure")
                    })
                }
            }
        }
    }

    func lovesButtonTapped(cell:StreamFooterCell) {
        println("lovesButtonTapped")
    }

    func repostButtonTapped(cell:StreamFooterCell) {
        println("repostButtonTapped")
    }

    func shareButtonTapped(cell: StreamFooterCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                if let shareLink = post.shareLink {
                    println("shareLink = \(shareLink)")
                    let activityVC = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
                    presentingController?.presentViewController(activityVC, animated: true) { }
                }
            }
        }
    }

// MARK: - Private

    private func commentLoadSuccess(jsonables:[JSONAble], indexPath:NSIndexPath, cell:StreamFooterCell) {
        var parser = StreamCellItemParser()
        self.dataSource.addUnsizedCellItems(parser.commentCellItems(jsonables as [Comment]), startingIndexPath:indexPath) { (indexPaths) -> () in
            self.collectionView.insertItemsAtIndexPaths(indexPaths)
        }
        cell.commentsButton.enabled = true
    }

    private func commentLoadFailure(error:NSError, statusCode:Int?) {

    }

}