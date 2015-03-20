//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class PostDetailViewController: StreamableViewController {

    var post : Post?
    var detailCellItems : [StreamCellItem]?
    var unsizedCellItems : [StreamCellItem]?
    var navigationBar : ElloNavigationBar!
    var streamViewController : StreamViewController!
    var streamKind: StreamKind?
    let postParam: String

    convenience init(post : Post, items: [StreamCellItem]) {
        self.init(post: post, items: items, unsized: [])
    }

    convenience init(post : Post, unsized: [StreamCellItem]) {
        self.init(post: post, items: [], unsized: unsized)
    }

    required init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        PostService.loadPost(postParam,
            success: postLoaded,
            failure: nil
        )
    }

    required init(post : Post, items: [StreamCellItem], unsized: [StreamCellItem]) {
        self.post = post
        self.postParam = post.postId
        self.detailCellItems = items
        self.unsizedCellItems = unsized

        super.init(nibName: nil, bundle: nil)
        self.streamKind = StreamKind.PostDetail(postParam: post.postId)
        self.title = post.author?.atName ?? "Post Detail"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        if let post = post {
            postDidLoad()
            loadComments()
        }
    }

    override func showNavBars(scrollToBottom : Bool) {
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

    override func hideNavBars() {
        super.hideNavBars()
        navigationBar.frame = navigationBar.frame.atY(-navigationBar.frame.height - 1)
        streamViewController.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height)
    }

// MARK : private

    private func postLoaded(post: Post) {
        self.post = post
        streamKind = StreamKind.PostDetail(postParam: post.postId)
        let parser = StreamCellItemParser()
        self.unsizedCellItems = parser.parse([post], streamKind: streamKind!) + parser.parse(post.comments, streamKind: streamKind!)
        self.title = post.author?.atName ?? "Post Detail"
        postDidLoad()
    }

    private func postDidLoad() {
        setupNavigationBar()
        setupStreamController()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        self.view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItems = [item]
        self.fixNavBarItemPadding()
        navigationBar.items = [self.navigationItem]
    }

    private func setupStreamController() {
        streamViewController = StreamViewController.instantiateFromStoryboard()
        streamViewController.streamKind = streamKind!
        streamViewController.currentUser = currentUser
        streamViewController.postTappedDelegate = self
        streamViewController.streamScrollDelegate = self
        streamViewController.userTappedDelegate = self

        streamViewController.willMoveToParentViewController(self)
        self.view.insertSubview(streamViewController.view, belowSubview: navigationBar)
        streamViewController.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)

        if let detailCellItems = detailCellItems {
            streamViewController.addStreamCellItems(detailCellItems)
        }
        if let unsizedCellItems = unsizedCellItems {
            streamViewController.addUnsizedCellItems(unsizedCellItems)
        }
    }

    private func loadComments() {
        if let post = post {
            streamViewController.streamService.loadMoreCommentsForPost(post.postId,
                success: { (jsonables, responseConfig) in
                    self.streamViewController.addUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: self.streamViewController.streamKind))
                    self.streamViewController.doneLoading()
                },
                failure: { (error, statusCode) in
                    println("failed to load comments (reason: \(error))")
                    self.streamViewController.doneLoading()
                }
            )

        }
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        if let selfPost = self.post {
            if post.postId != selfPost.postId {
                super.postTapped(post, initialItems: initialItems)
            }
        }
    }
}
