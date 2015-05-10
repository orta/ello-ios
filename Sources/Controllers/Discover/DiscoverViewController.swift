//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public class DiscoverViewController: StreamableViewController {

    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!

    required public init() {
        super.init(nibName: "DiscoverViewController", bundle: nil)
        title = NSLocalizedString("Discover", comment: "Discover")
        streamViewController.streamKind = .Discover(type: .Recommended, seed: Int(NSDate().timeIntervalSince1970), perPage: 50)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        streamViewController.loadInitialPage()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
    }

    override public func showNavBars(scrollToBottom : Bool) {
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

    override public func hideNavBars() {
        super.hideNavBars()
        navigationBarTopConstraint.constant = -navigationBar.frame.height - 1
        self.view.layoutIfNeeded()
    }

    // MARK: - IBActions

    @IBAction func importMyContactsTapped(sender: UIButton) {
        let responder = targetForAction("onInviteFriends", withSender: self) as? InviteResponder
        responder?.onInviteFriends()
    }
}
