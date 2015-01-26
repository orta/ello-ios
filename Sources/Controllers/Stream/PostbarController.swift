//
//  PostbarController.swift
//  Ello
//
//  Created by Sean on 1/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class PostbarController:NSObject, PostbarDelegate {

    let collectionView:UICollectionView
    let dataSource:StreamDataSource

    init(collectionView:UICollectionView, dataSource:StreamDataSource) {
        self.collectionView = collectionView
        self.dataSource = dataSource
    }

    // Mark:

    func viewsButtonTapped(cell:StreamFooterCell) {
        println("viewsButtonTapped")
    }

    func commentsButtonTapped(cell:StreamFooterCell) {
        cell.commentsButton.enabled = false
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                if cell.commentsOpened {
                    let indexPaths = self.dataSource.commentIndexPathsForPost(post)
                    if let first = indexPaths.first {
                        let range = Range(start: first.item,  end: first.item + countElements(indexPaths))
                        self.dataSource.streamCellItems.removeRange(range)
                        // self.collectionView.dataSource = self.dataSource
                        self.collectionView.deleteItemsAtIndexPaths(indexPaths)
                    }
                    cell.commentsButton.enabled = true
                }
                else {
                    let streamService = StreamService()
                    streamService.loadMoreCommentsForPost(post.postId, success: {
                        self.commentLoadSuccess($0, indexPath: indexPath, cell: cell)
                        }, failure: commentLoadFailure)
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

    // Mark: - Private

    private func commentLoadSuccess(streamables:[Streamable], indexPath:NSIndexPath, cell:StreamFooterCell) {
        self.dataSource.addStreamables(streamables, completion: { (indexPaths) -> () in
            self.collectionView.dataSource = self.dataSource
            self.collectionView.insertItemsAtIndexPaths(indexPaths)
        }, startingIndexPath:indexPath)
        cell.commentsButton.enabled = true
    }

    private func commentLoadFailure(error:NSError, statusCode:Int?) {

    }

}