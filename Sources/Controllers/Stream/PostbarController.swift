//
//  PostbarController.swift
//  Ello
//
//  Created by Sean on 1/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class PostbarController: NSObject, PostbarDelegate {

    let presentingController: StreamViewController
    let collectionView: UICollectionView
    let dataSource: StreamDataSource
    var currentUser: User?

    // on the post detail screen, the comments don't show/hide
    var toggleableComments: Bool = true

    public init(collectionView: UICollectionView, dataSource: StreamDataSource, presentingController: StreamViewController) {
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.collectionView.dataSource = dataSource
        self.presentingController = presentingController
    }

    // MARK:

    public func viewsButtonTapped(cell:UICollectionViewCell) {
        postTappedForCell(cell)
    }

    public func commentsButtonTapped(cell:StreamFooterCell, commentsButton: CommentButton) {

        if !toggleableComments {
            cell.cancelCommentLoading()
            return
        }

        if let indexPath = collectionView.indexPathForCell(cell),
           let item = dataSource.visibleStreamCellItem(at: indexPath),
           let post = item.jsonable as? Post
        {
            cell.commentsButton.enabled = false
            if cell.commentsOpened {
                let indexPaths = self.dataSource.removeCommentsForPost(post)
                self.collectionView.deleteItemsAtIndexPaths(indexPaths)
                cell.commentsButton.enabled = true
                item.state = .Collapsed
                cell.commentsButton.finishAnimation()
            }
            else {
                let streamService = StreamService()
                item.state = .Loading
                streamService.loadMoreCommentsForPost(post.postId,
                    success: { (comments, responseConfig) in
                        item.state = .Expanded
                        commentsButton.finishAnimation()
                        let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                        self.commentLoadSuccess(post, comments: comments, indexPath: nextIndexPath, cell: cell)
                    },
                    failure: { _ in
                        item.state = .Collapsed
                        cell.cancelCommentLoading()
                        println("comment load failure")
                    },
                    noContent: {
                        item.state = .Expanded
                        commentsButton.finishAnimation()
                        let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                        self.commentLoadSuccess(post, comments: [], indexPath: nextIndexPath, cell: cell)
                    }
                )
            }
        }
        else {
            cell.cancelCommentLoading()
        }
    }

    public func deleteButtonTapped(cell:UICollectionViewCell) {
        println("deleteButtonTapped")
    }

    public func lovesButtonTapped(cell:UICollectionViewCell) {
        println("lovesButtonTapped")
    }

    public func repostButtonTapped(cell:UICollectionViewCell) {
        println("repostButtonTapped")
    }

    public func shareButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                if let shareLink = post.shareLink {
                    println("shareLink = \(shareLink)")
                    let activityVC = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
                    presentingController.presentViewController(activityVC, animated: true) { }
                }
            }
        }
    }

    public func flagPostButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let flagger = ContentFlagger(presentingController: presentingController,
                    flaggableId: post.postId,
                    flaggableContentType: .Post,
                    commentPostId: nil)

                flagger.displayFlaggingSheet()
            }
        }
    }

    public func flagCommentButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let comment = dataSource.commentForIndexPath(indexPath) {
                let flagger = ContentFlagger(presentingController: presentingController,
                    flaggableId: comment.commentId,
                    flaggableContentType: .Comment,
                    commentPostId: comment.parentPost?.postId)

                flagger.displayFlaggingSheet()
            }
        }
    }

    public func replyToPostButtonTapped(cell:UICollectionViewCell) {
        println("reply to post button tapped")
    }

    public func replyToCommentButtonTapped(cell:UICollectionViewCell) {
        println("reply to comment button tapped")
    }

// MARK: - Private

    private func postTappedForCell(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            if let post = dataSource.postForIndexPath(indexPath) {
                let items = self.dataSource.cellItemsForPost(post)
                // This is a bit dirty, we should not call a method on a compositionally held
                // controller's postTappedDelegate. Need to chat about this with the crew.
                presentingController.postTappedDelegate?.postTapped(post, initialItems: items)
            }
        }
    }

    private func commentLoadSuccess(post: Post, comments jsonables:[JSONAble], indexPath: NSIndexPath, cell: StreamFooterCell) {
        self.appendCreateCommentItem(post, at: indexPath)
        let commentsStartingIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)

        let items = StreamCellItemParser().parse(jsonables, streamKind: StreamKind.Friend)
        self.dataSource.insertUnsizedCellItems(items,
            withWidth: self.collectionView.frame.width,
            startingIndexPath: commentsStartingIndexPath) { (indexPaths) in
                self.collectionView.insertItemsAtIndexPaths(indexPaths)
                cell.commentsButton.enabled = true
            }
    }

    private func appendCreateCommentItem(post: Post, at indexPath: NSIndexPath) {
        if let currentUser = currentUser {
            let comment = Comment.newCommentForPost(post, currentUser: currentUser)
            let createCommentItem = StreamCellItem(jsonable: comment,
                type: .CreateComment,
                data: nil,
                oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
                multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
                isFullWidth: true)

            let items = [createCommentItem]
            self.dataSource.insertStreamCellItems(items, startingIndexPath: indexPath)
            self.collectionView.insertItemsAtIndexPaths([indexPath])
        }
    }

    private func commentLoadFailure(error:NSError, statusCode:Int?) {
    }

}
