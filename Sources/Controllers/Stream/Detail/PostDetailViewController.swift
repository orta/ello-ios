//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class PostDetailViewController: StreamableViewController, CreateCommentDelegate {

    var post: Post?
    var postParam: String!
    let streamViewController : StreamViewController = StreamViewController.instantiateFromStoryboard()
    let startOfComments: Int = 0
    var navigationBar: ElloNavigationBar!

    required public init(postParam: String) {
        self.postParam = postParam
        self.startOfComments = 0
        super.init(nibName: nil, bundle: nil)
        setupNavigationBar()
        setupStreamViewController()

        PostService().loadPost(postParam,
            streamKind: streamKind,
            success: postLoaded,
            failure: nil
        )
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        navigationBar.frame = navigationBar.frame.atY(0)
        streamViewController.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)

        if scrollToBottom {
            if let scrollView = streamViewController.collectionView {
                let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                if contentOffsetY > 0 {
                    scrollView.scrollEnabled = false
                    scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                    scrollView.scrollEnabled = true
                }
            }
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        navigationBar.frame = navigationBar.frame.atY(-navigationBar.frame.height - 1)
        streamViewController.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height)
    }

// MARK : private

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [self.navigationItem]
    }

    private func setupStreamViewController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamKind = .PostDetail(postParam: self.postParam)
        streamViewController.createCommentDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.streamScrollDelegate = self
        streamViewController.userTappedDelegate = self
        streamViewController.postbarController!.toggleableComments = false

        streamViewController.willMoveToParentViewController(self)
        view.insertSubview(streamViewController.view, belowSubview: navigationBar)
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)

        streamViewController.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

    private func postLoaded(post: Post, responseConfig: ResponseConfig) {
        self.post = post
        // need to reassign the userParam to the id for paging
        postParam = post.id
        // need to reassign the streamKind so that the comments can page based off the post.id from the ElloAPI.path
        // same for when tapping on a post token in a post this will replace '~CRAZY-TOKEN' with the correct id for paging to work
        streamViewController.streamKind = StreamKind.PostDetail(postParam: postParam)
        streamViewController.responseConfig = responseConfig
        title = post.author?.atName ?? "Post Detail"
        let parser = StreamCellItemParser()
        var items = parser.parse([post], streamKind: streamViewController.streamKind)
        // add in the comment button
        items.append(StreamCellItem(
            jsonable: Comment.newCommentForPost(post, currentUser: currentUser!),
            type: .CreateComment,
            data: nil,
            oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
            multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
            isFullWidth: true)
        )
        if let comments = post.comments {
            items += parser.parse(comments, streamKind: streamViewController.streamKind)
        }
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
        startOfComments += items.count
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        streamViewController.refreshableIndex = startOfComments
    }

//    private func postDidLoad() {
//        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
//        streamViewController.streamKind = streamKind!
//
//        if let detailCellItems = detailCellItems {
//            streamViewController.appendStreamCellItems(detailCellItems)
//        }
//        if let unsizedCellItems = unsizedCellItems {
//            streamViewController.appendUnsizedCellItems(unsizedCellItems, withWidth: nil)
//        }
//        streamViewController.refreshableIndex = self.startOfComments
//    }
//
//    private func loadComments() {
//        if let post = post {
//            streamViewController.streamService.loadMoreCommentsForPost(
//                post.id,
//                streamKind: streamKind,
//                success: { (jsonables, responseConfig) in
//                    self.appendCreateCommentItem()
//                    self.streamViewController.responseConfig = responseConfig
//                    self.streamViewController.removeRefreshables()
//                    let newCommentItems = StreamCellItemParser().parse(jsonables, streamKind: self.streamKind!)
//                    self.streamViewController.appendUnsizedCellItems(newCommentItems, withWidth: nil)
//                    self.streamViewController.doneLoading()
//                },
//                failure: { (error, statusCode) in
//                    self.appendCreateCommentItem()
//                    println("failed to load comments (reason: \(error))")
//                    self.streamViewController.doneLoading()
//                },
//                noContent: {
//                    self.appendCreateCommentItem()
//
//                    self.streamViewController.removeRefreshables()
//                    self.streamViewController.doneLoading()
//                }
//            )
//        }
//    }

//    private func appendCreateCommentItem() {
//        if hasAddedCommentBar { return }
//
//        if let post = post {
//            hasAddedCommentBar = true
//
//            let controller = self.streamViewController
//            let comment = Comment.newCommentForPost(post, currentUser: self.currentUser!)
//            let createCommentItem = StreamCellItem(jsonable: comment,
//                type: .CreateComment,
//                data: nil,
//                oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
//                multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
//                isFullWidth: true)
//
//            let items = [createCommentItem]
//            controller.appendStreamCellItems(items)
//            self.startOfComments += items.count
//            controller.refreshableIndex = self.startOfComments
//        }
//    }

    override public func postTapped(post: Post, initialItems: [StreamCellItem], streamKind: StreamKind) {
        if let selfPost = self.post {
            if post.id != selfPost.id {
                super.postTapped(post, initialItems: initialItems, streamKind: streamKind)
            }
        }
    }

    override public func commentCreated(comment: Comment, fromController streamViewController: StreamViewController) {
        let newCommentItems = StreamCellItemParser().parse([comment], streamKind: streamViewController.streamKind)

        let startingIndexPath = NSIndexPath(forRow: self.startOfComments, inSection: 0)
        streamViewController.insertUnsizedCellItems(newCommentItems, startingIndexPath: startingIndexPath)
    }

}
