//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class DiscoverViewController: StreamableViewController {

    let streamViewController = StreamViewController.instantiateFromStoryboard()


    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    required init() {
        super.init(nibName: "DiscoverViewController", bundle: nil)
        title = "Discover"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
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
        navigationBarTopConstraint.constant = -navigationBar.frame.height - 1
        self.view.layoutIfNeeded()
    }

    private func setupStreamController() {
        streamViewController.streamKind = .Discover(type: .Recommended, seed: Int(NSDate().timeIntervalSince1970), perPage: 50)
        streamViewController.postTappedDelegate = self
        streamViewController.streamScrollDelegate = self
        streamViewController.userTappedDelegate = self

        streamViewController.willMoveToParentViewController(self)
        viewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = viewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
        streamViewController.loadInitialPage()
    }

    // MARK: - IBActions

    @IBAction func importMyContactsTapped(sender: UIButton) {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }

}
