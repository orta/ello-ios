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
        updateInsets()

        if shouldReload {
            shouldReload = false
            streamViewController.loadInitialPage()
        }
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets()
    }

    // MARK : private

    private func reloadEntirePostDetail() {
        PostService().loadPost(
            postParam,
            streamKind: .PostDetail(postParam: postParam),
            success: postLoaded,
            failure: { (error, statusCode) in
                self.showPostLoadFailure()
                self.streamViewController.doneLoading()
            }
        )
    }

    private func showPostLoadFailure() {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
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
        // clear out this view
        streamViewController.clearForInitialLoad()
        // set name
        title = post.author?.atName ?? "Post Detail"
        let parser = StreamCellItemParser()
        var items = parser.parse([post], streamKind: streamViewController.streamKind)
        // add in the comment button if we have a current user
        if let currentUser = currentUser {
            items.append(StreamCellItem(
                jsonable: Comment.newCommentForPost(post, currentUser: currentUser),
                type: .CreateComment,
                data: nil,
                oneColumnCellHeight: StreamCreateCommentCell.Size.Height,
                multiColumnCellHeight: StreamCreateCommentCell.Size.Height,
                isFullWidth: true)
            )
        }
        if let comments = post.comments {
            items += parser.parse(comments, streamKind: streamViewController.streamKind)
        }
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width)
        streamViewController.initialDataLoaded = true
        streamViewController.doneLoading()
    }

    override public func postTapped(post: Post) {
        if let selfPost = self.post {
            if post.id != selfPost.id {
                super.postTapped(post)
            }
        }
    }
}
