//
//  PostDetailViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class PostDetailViewController: StreamableViewController, CreateCommentDelegate {

    var shouldReload = false
    var post: Post?
    var postParam: String!
    var startOfComments: Int = 0
    var navigationBar: ElloNavigationBar!

    required public init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = reloadEntirePostDetail
        streamViewController.loadInitialPage()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        streamViewController.streamKind = .PostDetail(postParam: postParam)
        view.backgroundColor = .whiteColor()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return view
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if shouldReload {
            shouldReload = false
            streamViewController.loadInitialPage()
        }
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

    private func reloadEntirePostDetail() {
        PostService().loadPost(
            postParam,
            streamKind: .PostDetail(postParam: postParam),
            success: postLoaded,
            failure: nil
        )
    }

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [self.navigationItem]
    }

    private func postLoaded(post: Post, responseConfig: ResponseConfig) {
        self.post = post
        // need to reassign the userParam to the id for paging
        postParam = post.id
        // need to reassign the streamKind so that the comments can page based off the post.id from the ElloAPI.path
        // same for when tapping on a post token in a post this will replace '~CRAZY-TOKEN' with the correct id for paging to work
        streamViewController.streamKind = .PostDetail(postParam: postParam)
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
        startOfComments = items.count
        if let comments = post.comments {
            items += parser.parse(comments, streamKind: streamViewController.streamKind)
        }
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.doneLoading()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        streamViewController.refreshableIndex = startOfComments
    }

    override public func postTapped(post: Post) {
        if let selfPost = self.post {
            if post.id != selfPost.id {
                super.postTapped(post)
            }
        }
    }

//    override public func commentCreated(comment: Comment, fromController streamViewController: StreamViewController) {
//        let newCommentItems = StreamCellItemParser().parse([comment], streamKind: streamViewController.streamKind)
//
//        let startingIndexPath = NSIndexPath(forRow: startOfComments, inSection: 0)
//        streamViewController.insertUnsizedCellItems(newCommentItems, startingIndexPath: startingIndexPath)
//        // load comments again?
//    }

}
