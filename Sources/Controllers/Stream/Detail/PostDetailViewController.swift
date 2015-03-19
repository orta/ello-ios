//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class PostDetailViewController: StreamableViewController {

    var post : Post
    var detailCellItems : [StreamCellItem]
    var unsizedCellItems : [StreamCellItem]
    var navigationBar : ElloNavigationBar!
    var streamViewController : StreamViewController!

    convenience init(post : Post, items: [StreamCellItem]) {
        self.init(post: post, items: items, unsized: [])
    }

    convenience init(post : Post, unsized: [StreamCellItem]) {
        self.init(post: post, items: [], unsized: unsized)
    }

    required init(post : Post, items: [StreamCellItem], unsized: [StreamCellItem]) {
        self.post = post
        self.detailCellItems = items
        self.unsizedCellItems = unsized

        super.init(nibName: nil, bundle: nil)

        self.title = post.author?.atName ?? "Profile"
        self.view.backgroundColor = UIColor.whiteColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStreamController()

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
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

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        self.view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItem = item
        navigationBar.items = [self.navigationItem]
    }

    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.currentUser = currentUser
        controller.streamKind = .PostDetail(post: self.post)
        controller.postTappedDelegate = self
        controller.streamScrollDelegate = self
        controller.userTappedDelegate = self

        controller.willMoveToParentViewController(self)
        self.view.insertSubview(controller.view, belowSubview: navigationBar)
        controller.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)
        controller.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)

        controller.addStreamCellItems(self.detailCellItems)
        controller.addUnsizedCellItems(self.unsizedCellItems)

        controller.streamService.loadMoreCommentsForPost(post.postId,
            success: { (jsonables, responseConfig) in
                controller.addUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: controller.streamKind))
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load comments (reason: \(error))")
                controller.doneLoading()
            }
        )

        streamViewController = controller
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        if post.postId != self.post.postId {
            super.postTapped(post, initialItems: initialItems)
        }
    }
}
