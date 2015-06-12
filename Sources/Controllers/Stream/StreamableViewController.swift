//
//  StreamableViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

public protocol PostTappedDelegate : NSObjectProtocol {
    func postTapped(post: Post)
    func postTapped(#postId: String)
}

public protocol UserTappedDelegate : NSObjectProtocol {
    func userTapped(user: User)
    func userParamTapped(param: String)
}

public protocol CreateCommentDelegate: NSObjectProtocol {
    func createComment(post: Post, text:String, fromController: StreamViewController)
}

public protocol InviteResponder: NSObjectProtocol {
    func onInviteFriends()
}

public class StreamableViewController : BaseElloViewController, PostTappedDelegate {

    @IBOutlet weak var viewContainer: UIView!

    public let streamViewController = StreamViewController.instantiateFromStoryboard()

    func setupStreamController() {
        streamViewController.currentUser = currentUser
        streamViewController.streamScrollDelegate = self
        streamViewController.userTappedDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.createCommentDelegate = self

        streamViewController.willMoveToParentViewController(self)
        let streamViewContainer = viewForStream()
        streamViewContainer.addSubview(streamViewController.view)
        streamViewController.view.frame = streamViewContainer.bounds
        streamViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        addChildViewController(streamViewController)
        streamViewController.didMoveToParentViewController(self)
    }

    var scrollLogic: ElloScrollLogic!

    func viewForStream() -> UIView {
        return viewContainer
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let hidden = elloTabBarController?.tabBarHidden {
            willPresentStreamable(!hidden)
        }
        let hidden = elloTabBarController?.tabBarHidden ?? false
        UIApplication.sharedApplication().setStatusBarHidden(hidden, withAnimation: .Slide)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupStreamController()
        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    private func willPresentStreamable(navBarsVisible : Bool) {
        UIView.setAnimationsEnabled(false)
        if navBarsVisible {
            showNavBars(false)
        }
        else {
            hideNavBars()
        }
        UIView.setAnimationsEnabled(true)
        scrollLogic.isShowing = navBarsVisible
    }

    func navBarsVisible() -> Bool {
        return !(elloTabBarController?.tabBarHidden ?? false)
    }

    func updateInsets(#navBar: UIView?, streamController controller: StreamViewController, navBarsVisible visible: Bool? = nil) {
        let topInset: CGFloat
        let bottomInset: CGFloat
        if visible ?? navBarsVisible() {
            topInset = navBar?.frame.size.height ?? 0
            bottomInset = ElloTabBar.Size.height
        }
        else {
            topInset = 0
            bottomInset = 0
        }

        controller.contentInset.top = topInset
        controller.contentInset.bottom = bottomInset
    }

    func positionNavBar(navBar: UIView, visible: Bool, withConstraint navigationBarTopConstraint: NSLayoutConstraint? = nil, animated: Bool = true) {
        let upAmount: CGFloat
        if visible {
            upAmount = 0
        }
        else {
            upAmount = navBar.frame.size.height + 1
        }
        navigationBarTopConstraint?.constant = upAmount
        animate(animated: animated) {
            navBar.frame.origin.y = -upAmount
        }
        UIApplication.sharedApplication().setStatusBarHidden(!visible, withAnimation: .None)
    }

    func showNavBars(scrollToBottom : Bool) {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }

    func hideNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(true, animated: true)
        }
    }

    func scrollToBottom(controller: StreamViewController) {
        if let scrollView = streamViewController.collectionView {
            let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            if contentOffsetY > 0 {
                scrollView.scrollEnabled = false
                scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                scrollView.scrollEnabled = true
            }
        }
    }

    @IBAction func backTapped(sender: UIButton) {
        if let controllers = self.navigationController?.childViewControllers
            where controllers.count > 1
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

// MARK: PostTappedDelegate

    public func postTapped(post: Post) {
        self.postTapped(postId: post.id)
    }

    public func postTapped(#postId: String) {
        let vc = PostDetailViewController(postParam: postId)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Search
public extension StreamableViewController {
    func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: SVGKImage(named: "search_normal.svg").UIImage!, style: .Done, target: self, action: Selector("searchButtonTapped"))
    }

    func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }
}

// MARK: UserTappedDelegate
extension StreamableViewController: UserTappedDelegate {
    public func userTapped(user: User) {
        userParamTapped(user.id)
    }

    public func userParamTapped(param: String) {
        if alreadyOnUserProfile(param) {
            return
        }
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func alreadyOnUserProfile(user: User) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController {
            let param = profileVC.userParam
            if param[param.startIndex] == "~" {
                let usernamePart = param[advance(param.startIndex, 1)..<param.endIndex]
                return user.username == usernamePart
            }
            else {
                return user.id == profileVC.userParam
            }
        }
        return false
    }
}

// MARK: CreateCommentDelegate
extension StreamableViewController: CreateCommentDelegate {
    public func createComment(post : Post, text: String, fromController: StreamViewController) {
        let vc = OmnibarViewController(parentPost: post, defaultText: text)
        vc.currentUser = self.currentUser
        vc.onCommentSuccess() { (comment: Comment) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: StreamScrollDelegate
extension StreamableViewController : StreamScrollDelegate {
    public func streamViewDidScroll(scrollView : UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    public func streamViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    public func streamViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

// MARK: InviteResponder
extension StreamableViewController: InviteResponder {
    public func onInviteFriends() {
        Tracker.sharedTracker.inviteFriendsTapped()
        switch AddressBook.authenticationStatus() {
        case .Authorized:
            proceedWithImport()
        case .NotDetermined:
            promptForAddressBookAccess()
        case .Denied:
            let message = NSLocalizedString("Access to your contacts has been denied.  If you want to search for friends, you will need to grant access from Settings.", comment: "Access to contacts denied by user")
            displayAddressBookAlert(message)
        case .Restricted:
            let message = NSLocalizedString("Access to your contacts has been denied by the system.", comment: "Access to contacts denied by system")
            displayAddressBookAlert(message)
        }
    }

    // MARK: - Private

    private func promptForAddressBookAccess() {
        let message = NSLocalizedString("Import your contacts to find your friends on Ello.\n\nEllo does not sell user data and never contacts anyone without your permission.", comment: "Import your contacts permission prompt")
        let alertController = AlertViewController(message: message)

        let importMessage = NSLocalizedString("Find your friends", comment: "Find your friends action")
        let action = AlertAction(title: importMessage, style: .Dark) { action in
            Tracker.sharedTracker.importContactsInitiated()
            self.proceedWithImport()
        }
        alertController.addAction(action)

        let cancelMessage = NSLocalizedString("Not now", comment: "Not now action")
        let cancelAction = AlertAction(title: cancelMessage, style: .Light) { _ in
            Tracker.sharedTracker.importContactsDenied()
        }
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: .None)
    }

    private func proceedWithImport() {
        Tracker.sharedTracker.addressBookAccessed()
        AddressBook.getAddressBook { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case let .Success(box):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(true)
                    let vc = AddFriendsViewController(addressBook: box.value)
                    vc.currentUser = self.currentUser
                    vc.userTappedDelegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                case let .Failure(box):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(false)
                    self.displayAddressBookAlert(box.value.rawValue)
                    return
                }
            }
        }
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = AlertViewController(
            message: "We were unable to access your address book\n\(message)"
        )

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: .None)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: .None)
    }

}
