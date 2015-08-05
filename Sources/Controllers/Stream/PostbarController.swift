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
    func lovesButtonTapped(cell: StreamFooterCell, indexPath: NSIndexPath)
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
        if let post = postForIndexPath(indexPath) {
            Tracker.sharedTracker.viewsButtonTapped(post: post)
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

        if  let indexPath = collectionView.indexPathForCell(cell),
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
                        if let updatedIndexPath = self.dataSource.indexPathForItem(item) {
                            item.state = .Expanded
                            imageLabelControl.finishAnimation()
                            let nextIndexPath = NSIndexPath(forItem: updatedIndexPath.row + 1, inSection: updatedIndexPath.section)
                            self.commentLoadSuccess(post, comments: comments, indexPath: nextIndexPath, cell: cell)
                        }
                    },
                    failure: { _ in
                        item.state = .Collapsed
                        cell.cancelCommentLoading()
                        println("comment load failure")
                    },
                    noContent: {
                        if let updatedIndexPath = self.dataSource.indexPathForItem(item) {
                            item.state = .Expanded
                            imageLabelControl.finishAnimation()
                            let nextIndexPath = NSIndexPath(forItem: updatedIndexPath.row + 1, inSection: updatedIndexPath.section)
                            self.commentLoadSuccess(post, comments: [], indexPath: nextIndexPath, cell: cell)
                        }
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
            if let user = self.currentUser {
                if let userPostCount = user.postsCount {
                    user.postsCount = userPostCount - 1
                    postNotification(CurrentUserChangedNotification, user)
                }
            }
            if let post = self.postForIndexPath(indexPath) {
                postNotification(PostChangedNotification, (post, .Delete))
                PostService().deletePost(post.id,
                    success: nil,
                    failure: { (error, statusCode)  in
                        // TODO: add error handling
                        println("failed to delete post, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                    }
                )
            }
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        logPresentingAlert(presentingController?.readableClassName() ?? "PostbarController")
        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }

    public func deleteCommentButtonTapped(indexPath: NSIndexPath) {
        let message = NSLocalizedString("Delete Comment?", comment: "Delete Comment")
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .Dark) {
            action in
            if let comment = self.commentForIndexPath(indexPath), let postId = comment.parentPost?.id {
                // comment deleted
                postNotification(CommentChangedNotification, (comment, .Delete))
                // post comment count updated
                if let post = comment.parentPost, let count = post.commentsCount {
                    post.commentsCount = count - 1
                    postNotification(PostChangedNotification, (post, .Update))
                }
                PostService().deleteComment(postId, commentId: comment.id,
                    success: nil,
                    failure: { (error, statusCode)  in
                        // TODO: add error handling
                        println("failed to delete comment, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                    }
                )
            }
        }
        let noAction = AlertAction(title: NSLocalizedString("No", comment: "No"), style: .Light, handler: .None)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        logPresentingAlert(presentingController?.readableClassName() ?? "PostbarController")
        presentingController?.presentViewController(alertController, animated: true, completion: .None)
    }

    public func lovesButtonTapped(cell: StreamFooterCell, indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath) {
            Tracker.sharedTracker.postLoved(post)
            cell.lovesControl.userInteractionEnabled = false
            if post.loved { unlovePost(post, cell: cell) }
            else { lovePost(post, cell: cell) }
        }
    }

    private func unlovePost(post: Post, cell: StreamFooterCell) {
        Tracker.sharedTracker.postUnloved(post)
        if let count = post.lovesCount {
            post.lovesCount = count - 1
            post.loved = false
            postNotification(PostChangedNotification, (post, .Update))
        }
        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount - 1
            postNotification(CurrentUserChangedNotification, user)
        }
        let service = LovesService()
        service.unlovePost(
            postId: post.id,
            success: {
                cell.lovesControl.userInteractionEnabled = true
            },
            failure: { error, statusCode in
                cell.lovesControl.userInteractionEnabled = true
                println("failed to unlove post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            }
        )
    }

    private func lovePost(post: Post, cell: StreamFooterCell) {
        Tracker.sharedTracker.postLoved(post)
        if let count = post.lovesCount {
            post.lovesCount = count + 1
            post.loved = true
            postNotification(PostChangedNotification, (post, .Update))
        }
        if let user = currentUser, let userLoveCount = user.lovesCount {
            user.lovesCount = userLoveCount + 1
            postNotification(CurrentUserChangedNotification, user)
        }
        LovesService().lovePost(
            postId: post.id,
            success: { (love, responseConfig) in
                postNotification(LoveChangedNotification, (love, .Create))
                cell.lovesControl.userInteractionEnabled = true
            },
            failure: { error, statusCode in
                cell.lovesControl.userInteractionEnabled = true
                println("failed to love post \(post.id), error: \(error.elloErrorMessage ?? error.localizedDescription)")
            }
        )
    }

    public func repostButtonTapped(indexPath: NSIndexPath) {
        if let post = self.postForIndexPath(indexPath) {
            Tracker.sharedTracker.postReposted(post)
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

            logPresentingAlert(presentingController?.readableClassName() ?? "PostbarController")
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
        if let user = currentUser, let userPostsCount = user.postsCount {
            user.postsCount = userPostsCount + 1
            postNotification(CurrentUserChangedNotification, user)
        }
        RePostService().repost(post: post,
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
            Tracker.sharedTracker.postShared(post)
            let activityVC = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
            if UI_USER_INTERFACE_IDIOM() == .Phone {
                logPresentingAlert(presentingController?.readableClassName() ?? "PostbarController")
                presentingController?.presentViewController(activityVC, animated: true) { }
            }
            else {
                let cell = dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
                activityVC.popoverPresentationController?.sourceView = cell
                activityVC.modalPresentationStyle = .Popover
                logPresentingAlert(presentingController?.readableClassName() ?? "PostbarController")
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

        var items = StreamCellItemParser().parse(jsonables, streamKind: StreamKind.Friend, currentUser: currentUser)

        if let currentUser = currentUser {
            let newComment = Comment.newCommentForPost(post, currentUser: currentUser)
            if post.commentsCount > ElloAPI.PostComments(postId: "").parameters["per_page"] as? Int {
                items.append(StreamCellItem(jsonable: newComment, type: .SeeMoreComments))
            }
            else {
                items.append(StreamCellItem(jsonable: newComment, type: .Spacer(height: 10.0)))
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
            let createCommentItem = StreamCellItem(jsonable: comment, type: .CreateComment)

            let items = [createCommentItem]
            self.dataSource.insertStreamCellItems(items, startingIndexPath: indexPath)
            self.collectionView.insertItemsAtIndexPaths([indexPath])
        }
    }

    private func commentLoadFailure(error:NSError, statusCode:Int?) {
    }

}
