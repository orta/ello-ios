//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class DiscoverViewController: StreamableViewController {

    let streamViewController: StreamViewController


    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    required override init() {
        self.streamViewController = StreamViewController.instantiateFromStoryboard()
        let seed = Int(NSDate().timeIntervalSince1970)
        self.streamViewController.streamKind = StreamKind.Discover(type: .Random, seed: seed, perPage: 50)
        super.init(nibName: "DiscoverViewController", bundle: nil)
        self.streamViewController.userTappedDelegate = self
        self.title = "Discover"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        navigationBarTopConstraint.constant = 0
        self.view.layoutIfNeeded()

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
        navigationBarTopConstraint.constant = navigationBar.frame.height + 1
        self.view.layoutIfNeeded()
    }

    private func setupStreamController() {
        streamViewController.streamScrollDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.userTappedDelegate = self

        streamViewController.willMoveToParentViewController(self)
        viewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = viewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
        streamViewController.loadInitialPage()
    }

    private func setupNavigationBar() {
        navigationItem.title = self.title
        navigationBar.items = [navigationItem]
    }
}

