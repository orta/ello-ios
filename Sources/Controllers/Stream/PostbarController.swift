//
//  PostbarController.swift
//  Ello
//
//  Created by Sean on 1/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public protocol PostbarDelegate : NSObjectProtocol {
    func viewsButtonTapped(indexPath: NSIndexPath)
    func commentsButtonTapped(cell: StreamFooterCell, imageLabelControl: ImageLabelControl)
    func deletePostButtonTapped(indexPath: NSIndexPath)
    func deleteCommentButtonTapped(indexPath: NSIndexPath)
    func lovesButtonTapped(indexPath: NSIndexPath)
    func repostButtonTapped(indexPath: NSIndexPath)
    func shareButtonTapped(indexPath: NSIndexPath)
    func flagPostButtonTapped(indexPath: NSIndexPath)
    func flagCommentButtonTapped(indexPath: NSIndexPath)
    func replyToCommentButtonTapped(indexPath: NSIndexPath)
}

public class PostbarController: NSObject, PostbarDelegate {

    weak var presentingController: StreamViewController?
    public var collectionView: UICollectionView
    public let dataSource: StreamDataSource
    public var currentUser: User?

    // on the post detail screen, the comments don't show/hide
    var toggleableComments: Bool = true

    public init(collectionView: UICollectionView, dataSource: StreamDataSource, presentingController: StreamViewController) {
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.collectionView.dataSource = dataSource
        self.presentingController = presentingController
    }

    // MARK:

    public func viewsButtonTapped(indexPath: NSIndexPath) {
        Tracker.sharedTracker.viewsButtonTapped()
        if let post = postForIndexPath(indexPath) {
            let items = self.dataSource.cellItemsForPost(post)
            // This is a bit dirty, we should not call a method on a compositionally held
            // controller's postTappedDelegate. Need to chat about this with the crew.
            presentingController?.postTappedDelegate?.postTapped(post)
        }
    }

    public func commentsButtonTapped(cell:StreamFooterCell, imageLabelControl: ImageLabelControl) {
        if dataSource.streamKind.isGridLayout {
            cell.cancelCommentLoading()
            if let indexPath = collectionView.indexPathForCell(cell) {
                self.viewsButtonTapped(indexPath)
            }
            return
        }

        if dataSource.streamKind.isDetail {
            return
        }

        imageLabelControl.highlighted = true
        if cell.commentsOpened {
            imageLabelControl.animate()
        }
        imageLabelControl.selected = cell.commentsOpened

        if !toggleableComments {
            cell.cancelCommentLoading()
            return
        }

        if let indexPath = collectionView.indexPathForCell(cell),
            let item = dataSource.visibleStreamCellItem(at: indexPath),
            let post = item.jsonable as? Post
        {
            cell.commentsControl.enabled = false
            if !cell.commentsOpened {
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

    public func deletePostButtonTapped(indexPath: NSIndexPath) {
        let message = NSLocalizedString("Delete Post?", comment: "Delete Post")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) {
            action in
            let service = PostService()
            if let post = self.postForIndexPath(indexPath) {
                service.deletePost(post.id,
                    success: {
                        postNotification(PostChangedNotification, (post, .Delete))
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

    public func deleteCommentButtonTapped(indexPath: NSIndexPath) {
        let message = NSLocalizedString("Delete Comment?", comment: "Delete Comment")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) {
            action in
            let service = PostService()
            if let comment = self.commentForIndexPath(indexPath), let postId = comment.parentPost?.id {
                service.deleteComment(postId, commentId: comment.id,
                    success: {
                        // comment deleted
                        postNotification(CommentChangedNotification, (comment, .Delete))
                        // post comment count updated
                        if let post = comment.parentPost, let count = post.commentsCount {
                            post.commentsCount = count - 1
                            postNotification(PostChangedNotification, (post, .Update))
                        }
                    }, failure: { (error, statusCode)  in
                        // TODO: add error handling
                        println("failed to delete comment, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                    }
                )
            }
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }


    public func lovesButtonTapped(indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath) {
            if post.loved { unlovePost(post) }
            else { lovePost(post) }
        }
    }

    private func unlovePost(post: Post) {
        let service = LovesService()
        service.unlovePost(
            postId: post.id,
            success: {
                if let count = post.loveCount {
                    post.loveCount = count - 1
                    postNotification(PostChangedNotification, (post, .Update))
                }
                Tracker.sharedTracker.postUnloved()
            },
            failure: { error, statusCode in
                println("failed to unlove post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            }
        )
    }

    private func lovePost(post: Post) {
        let service = LovesService()
        service.lovePost(
            postId: post.id,
            success: {
                if let count = post.loveCount {
                    post.loveCount = count + 1
                    postNotification(PostChangedNotification, (post, .Update))
                }
                Tracker.sharedTracker.postLoved()
            },
            failure: { error, statusCode in
                println("failed to love post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            }
        )
    }

    public func repostButtonTapped(indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath) {
            Tracker.sharedTracker.postReposted()
            let message = NSLocalizedString("Repost?", comment: "Repost acknowledgment")
            let alertController = AlertViewController(message: message)
            alertController.autoDismiss = false

            let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes button"), style: .Dark) { action in
                self.createRepost(post, alertController: alertController)
            }
            let noAction = AlertAction(title: NSLocalizedString("No", comment: "No button"), style: .Light) { action in
                alertController.dismiss()
            }

            alertController.addAction(yesAction)
            alertController.addAction(noAction)

            presentingController?.presentViewController(alertController, animated: true, completion: .None)
        }
    }

    private func createRepost(post: Post, alertController: AlertViewController)
    {
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
                postNotification(PostChangedNotification, (repost, .Create))
                alertController.contentView = nil
                alertController.message = NSLocalizedString("Success!", comment: "Successful repost alert")
                delay(1) {
                    alertController.dismiss()
                }
            }, failure: { (error, statusCode)  in
                alertController.contentView = nil
                alertController.message = NSLocalizedString("Could not create repost", comment: "Could not create repost message")
                alertController.autoDismiss = true
                alertController.dismissable = true
                let okAction = AlertAction(title: NSLocalizedString("OK", comment: "OK button"), style: .Light, handler: .None)
                alertController.addAction(okAction)
            }
        )
    }

    public func shareButtonTapped(indexPath: NSIndexPath) {
        if  let post = dataSource.postForIndexPath(indexPath),
            let shareLink = post.shareLink
        {
            let cell = dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
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

    public func flagPostButtonTapped(indexPath: NSIndexPath) {
        if let post = dataSource.postForIndexPath(indexPath) {
            let flagger = ContentFlagger(presentingController: presentingController,
            flaggableId: post.id,
            contentType: .Post,
            commentPostId: nil)
            flagger.displayFlaggingSheet()
        }
    }

    public func flagCommentButtonTapped(indexPath: NSIndexPath) {
        if let comment = dataSource.commentForIndexPath(indexPath) {
            let flagger = ContentFlagger(
                presentingController: presentingController,
                flaggableId: comment.id,
                contentType: .Comment,
                commentPostId: comment.postId
            )

            flagger.displayFlaggingSheet()
        }
    }

    public func replyToCommentButtonTapped(indexPath: NSIndexPath) {
        if let comment = commentForIndexPath(indexPath) {
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

    private func postForIndexPath(indexPath: NSIndexPath) -> Post? {
        return dataSource.postForIndexPath(indexPath)
    }

    private func commentForIndexPath(indexPath: NSIndexPath) -> Comment? {
        return dataSource.commentForIndexPath(indexPath)
    }

    private func commentLoadSuccess(post: Post, comments jsonables:[JSONAble], indexPath: NSIndexPath, cell: StreamFooterCell) {
        self.appendCreateCommentItem(post, at: indexPath)
        let commentsStartingIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)

        var items = StreamCellItemParser().parse(jsonables, streamKind: StreamKind.Friend)

        if let currentUser = currentUser {
            let newComment = Comment.newCommentForPost(post, currentUser: currentUser)
            if post.commentsCount > 25 {
                items.append(StreamCellItem(jsonable: newComment, type: .SeeMoreComments, data: nil, oneColumnCellHeight: 60.0, multiColumnCellHeight: 60.0, isFullWidth: true))
            }
            else {
                items.append(StreamCellItem(jsonable: newComment, type: .Spacer, data: nil, oneColumnCellHeight: 25.0, multiColumnCellHeight: 25.0, isFullWidth: true))
            }
        }

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
