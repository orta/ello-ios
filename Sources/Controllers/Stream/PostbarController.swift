//
//  PostbarController.swift
//  Ello
//
//  Created by Sean on 1/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation


public class PostbarController: NSObject, PostbarDelegate {

    weak var presentingController: StreamViewController?
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
        Tracker.sharedTracker.viewsButtonTapped()
        postTappedForCell(cell)
    }

    public func commentsButtonTapped(cell:StreamFooterCell, imageLabelControl: ImageLabelControl) {

        if !toggleableComments {
            cell.cancelCommentLoading()
            return
        }

        if let indexPath = collectionView.indexPathForCell(cell),
           let item = dataSource.visibleStreamCellItem(at: indexPath),
           let post = item.jsonable as? Post
        {
            cell.commentsControl.enabled = false
            if cell.commentsOpened {
                let indexPaths = self.dataSource.removeCommentsForPost(post)
                self.collectionView.deleteItemsAtIndexPaths(indexPaths)
                imageLabelControl.enabled = true
                item.state = .Collapsed
                imageLabelControl.finishAnimation()
                imageLabelControl.highlighted = false
            }
            else {
                let streamService = StreamService()
                item.state = .Loading
                streamService.loadMoreCommentsForPost(
                    post.id,
                    streamKind: dataSource.streamKind,
                    success: { (comments, responseConfig) in
                        item.state = .Expanded
                        imageLabelControl.finishAnimation()
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
                        imageLabelControl.finishAnimation()
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

    public func deletePostButtonTapped(cell:UICollectionViewCell) {
        let message = NSLocalizedString("Delete Post?", comment: "Delete Post")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) {
            action in
            let service = PostService()
            if let post = self.postForCell(cell) {
                service.deletePost(post.id,
                    success: {
                        postNotification(ExperienceUpdatedNotification, .PostChanged(id: post.id, change: .Delete))
                    }, failure: { (error, statusCode)  in
                        // TODO: add error handling
                        println("failed to delete post, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                    }
                )
            }
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }

    public func deleteCommentButtonTapped(cell:UICollectionViewCell) {
        let message = NSLocalizedString("Delete Comment?", comment: "Delete Comment")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) {
            action in
            let service = PostService()
            if let comment = self.commentForCell(cell), let postId = comment.parentPost?.id {
                service.deleteComment(postId, commentId: comment.id,
                    success: {
                        postNotification(ExperienceUpdatedNotification, .CommentChanged(commentId: comment.id, postId: postId, change: .Delete))
                    }, failure: { (error, statusCode)  in
                        // TODO: add error handling
                        println("failed to delete post, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                    }
                )
            }
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }


    public func lovesButtonTapped(cell: UICollectionViewCell) {
        println("lovesButtonTapped")
        Tracker.sharedTracker.postLoved()
    }

    public func repostButtonTapped(cell: UICollectionViewCell) {
        Tracker.sharedTracker.postReposted()
        let message = NSLocalizedString("Repost?", comment: "Repost acknowledgment")
        let alertController = AlertViewController(message: message)
        alertController.autoDismiss = false

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes button"), style: .Dark, handler: { action in
            self.createRepost(cell, alertController: alertController)
        })
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No button"), style: .Light, handler: { action in
            alertController.dismiss()
        })

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }

    public func createRepost(cell: UICollectionViewCell, alertController: AlertViewController) {
        if let post = self.postForCell(cell) {
            alertController.resetActions()
            alertController.dismissable = false

            let spinnerContainer = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.frame.size.width, height: 200))
            let spinner = ElloLogoView(frame: CGRect(origin: CGPointZero, size: ElloLogoView.Size.natural))
            spinner.center = spinnerContainer.bounds.center
            spinnerContainer.addSubview(spinner)
            alertController.contentView = spinnerContainer
            spinner.animateLogo()

            let service = RePostService()
            service.repost(post: post,
                success: { repost in
                    alertController.contentView = nil
                    alertController.message = NSLocalizedString("Success!", comment: "Successful repost alert")
                    Functional.delay(1) {
                        alertController.dismiss()
                    }
                }, failure: { (error, statusCode)  in
                    var errorTitle : String = error.localizedDescription
                    if let info = error.userInfo {
                        if let elloNetworkError = info[NSLocalizedFailureReasonErrorKey] as? ElloNetworkError {
                            errorTitle = elloNetworkError.title
                        }
                    }

                    alertController.contentView = nil
                    alertController.message = NSLocalizedString("Could not create repost", comment: "Could not create repost message")
                    alertController.autoDismiss = true
                    alertController.dismissable = true
                    let okAction = AlertAction(title: NSLocalizedString("OK", comment: "OK button"), style: .Light, handler: .None)
                    alertController.addAction(okAction)
                }
            )
        }
        else {
            alertController.dismiss()
        }
    }

    public func shareButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
           let post = dataSource.postForIndexPath(indexPath),
           let shareLink = post.shareLink
        {
            Tracker.sharedTracker.postShared()
            let activityVC = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                presentingController?.presentViewController(activityVC, animated: true) { }
            }
            else {
                activityVC.popoverPresentationController?.sourceView = cell
                activityVC.modalPresentationStyle = .Popover
                presentingController?.presentViewController(activityVC, animated: true) { }
            }
        }
    }

    public func flagPostButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
           let post = dataSource.postForIndexPath(indexPath)
        {
            let flagger = ContentFlagger(presentingController: presentingController,
                flaggableId: post.id,
                contentType: .Post,
                commentPostId: nil)
            flagger.displayFlaggingSheet()
        }
    }

    public func flagCommentButtonTapped(cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(cell),
           let comment = dataSource.commentForIndexPath(indexPath)
        {
            let flagger = ContentFlagger(presentingController: presentingController,
                flaggableId: comment.id,
                contentType: .Comment,
                commentPostId: comment.postId)

            flagger.displayFlaggingSheet()
        }
    }

    public func replyToCommentButtonTapped(cell:UICollectionViewCell) {
        if let comment = commentForCell(cell) {
            // This is a bit dirty, we should not call a method on a compositionally held
            // controller's createCommentDelegate. Can this use the responder chain when we have
            // parameters to pass?
            if let presentingController = presentingController,
                let post = comment.parentPost,
                let atName = comment.author?.atName
            {
                presentingController.createCommentDelegate?.createComment(post, text: "\(atName) ", fromController: presentingController)
            }
        }
    }

// MARK: - Private

    private func postForCell(cell: UICollectionViewCell) -> Post? {
        if let indexPath = collectionView.indexPathForCell(cell) {
            return dataSource.postForIndexPath(indexPath)
        }
        return nil
    }

    private func commentForCell(cell: UICollectionViewCell) -> Comment? {
        if let indexPath = collectionView.indexPathForCell(cell) {
            return dataSource.commentForIndexPath(indexPath)
        }
        return nil
    }

    private func postTappedForCell(cell: UICollectionViewCell) {
        if let post = postForCell(cell) {
            let items = self.dataSource.cellItemsForPost(post)
            // This is a bit dirty, we should not call a method on a compositionally held
            // controller's postTappedDelegate. Need to chat about this with the crew.
            presentingController?.postTappedDelegate?.postTapped(post)
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
                cell.commentsControl.enabled = true
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

