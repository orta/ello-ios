//
//  LovesViewController.swift
//  Ello
//
//  Created by Sean on 5/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class LovesViewController: StreamableViewController {

    var navigationBar: ElloNavigationBar!

    required public init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Loves", comment: "love stream")
        view.backgroundColor = .whiteColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44
        streamViewController.streamKind = StreamKind.Friend
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    override func viewForStream() -> UIView {
        return view
    }

    override public func didSetCurrentUser() {
        if isViewLoaded() {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets(navBar: navigationBar, streamController: streamViewController, navBarsVisible: false)
    }

// MARK: Private

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        animate {
            self.navigationBar.frame = self.navigationBar.frame.atY(0)
        }
        updateInsets()
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


}

