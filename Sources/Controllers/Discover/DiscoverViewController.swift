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
        if AddressBook.needsAuthentication() {
            displayContactActionSheet()
        } else {
            getAddressBook(.None)
        }
    }

    // MARK: - Private

    private func displayContactActionSheet() {
        let alertController = UIAlertController(
            title: "Import your contacts fo find your friends on Ello.",
            message: "Ello does not sell user data and never contacts anyone without your permission.",
            preferredStyle: .ActionSheet)

        let action = UIAlertAction(title: "Import my contacts", style: .Default, handler: getAddressBook)
        alertController.addAction(action)

        let cancelAction = UIAlertAction(title: "Not now", style: .Cancel, handler: .None)
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: .None)
    }

    private func getAddressBook(action: UIAlertAction?) {
        AddressBook.getAddressBook { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case let .Success(box):
                    let vc = AddFriendsContainerViewController(addressBook: box.unbox)
                    self.navigationController?.pushViewController(vc, animated: true)
                case let .Failure(box):
                    self.displayAddressBookAlert(box.unbox.rawValue)
                    return
                }
            }
        }
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = UIAlertController(
            title: "We were unable to access your address book",
            message: message,
            preferredStyle: .Alert
        )

        let action = UIAlertAction(title: "OK", style: .Default, handler: .None)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: .None)
    }
}

