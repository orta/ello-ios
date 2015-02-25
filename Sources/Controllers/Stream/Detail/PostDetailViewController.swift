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
    var scrollLogic: ElloScrollLogic!

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

        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    func showNavBars(scrollToBottom : Bool) {
        navigationBar.frame = navigationBar.frame.atY(0)
        if let tabBarController = self.tabBarController {
            tabBarController.tabBarHidden = false
        }

        for controller in childViewControllers as [StreamViewController] {
            controller.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)

            if scrollToBottom {
                if let scrollView = controller.collectionView {
                    if scrollView.frame.size.height > scrollView.contentSize.height {
                        let y : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                        scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
                    }
                }
            }
        }
    }

    func hideNavBars() {
        navigationBar.frame = navigationBar.frame.atY(-navigationBar.frame.height - 1)
        if let tabBarController = self.tabBarController {
            tabBarController.tabBarHidden = true
        }

        for controller in childViewControllers as [StreamViewController] {
            controller.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height)
        }
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
        controller.streamKind = .PostDetail(post: self.post)
        controller.postTappedDelegate = self
        controller.streamScrollDelegate = self

        controller.willMoveToParentViewController(self)
        self.view.insertSubview(controller.view, belowSubview: navigationBar)
        controller.view.frame = navigationBar.frame.fromBottom().withHeight(self.view.frame.height - navigationBar.frame.height)
        controller.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)

        controller.addStreamCellItems(self.detailCellItems)
        controller.addUnsizedCellItems(self.unsizedCellItems)

        let streamService = StreamService()
        streamService.loadMoreCommentsForPost(post.postId,
            success: { jsonables in
                var parser = StreamCellItemParser()
                controller.addUnsizedCellItems(parser.commentCellItems(jsonables as [Comment]))
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load comments (reason: \(error))")
                controller.doneLoading()
            }
        )
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        if post.postId != self.post.postId {
            super.postTapped(post, initialItems: initialItems)
        }
    }
}


// MARK: PostDetailViewController: StreamScrollDelegate
extension PostDetailViewController : StreamScrollDelegate {

    func streamViewDidScroll(scrollView : UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

}