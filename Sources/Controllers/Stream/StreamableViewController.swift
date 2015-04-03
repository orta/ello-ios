//
//  StreamableViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public protocol PostTappedDelegate : NSObjectProtocol {
    func postTapped(post : Post, initialItems: [StreamCellItem])
}

public protocol UserTappedDelegate : NSObjectProtocol {
    func userTapped(user : User)
}

public protocol CreateCommentDelegate: NSObjectProtocol {
    func createComment(post : Post)
}

public protocol InviteResponder: NSObjectProtocol {
    func onInviteFriends()
}

public class StreamableViewController : BaseElloViewController {

    var scrollLogic: ElloScrollLogic!

    override public func viewDidLoad() {
        super.viewDidLoad()

        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    func willPresentStreamable(navBarsVisible : Bool) {
        let view = self.view

        if navBarsVisible {
            showNavBars(false)
        }
        else {
            hideNavBars()
        }
        scrollLogic.isShowing = navBarsVisible
    }

    func didPresentStreamable() {}

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

    @IBAction func backTapped(sender: UIButton) {
        if let controllers = self.navigationController?.childViewControllers {
            if controllers.count > 1 {
                if let prev = controllers[controllers.count - 2] as? StreamableViewController {
                    prev.willPresentStreamable(scrollLogic.isShowing)
                    self.navigationController?.popViewControllerAnimated(true)
                    prev.didPresentStreamable()
                }
                else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }

    private func alreadyOnUserProfile(user: User) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController {
            let param = profileVC.userParam
            if param[param.startIndex] == "~" {
                let usernamePart = param[advance(param.startIndex, 1)..<param.endIndex]
                return user.username == usernamePart
            }
            else {
                return user.userId == profileVC.userParam
            }
        }
        return false
    }
}

// MARK: PostTappedDelegate
extension StreamableViewController: PostTappedDelegate {
    public func postTapped(post: Post, initialItems: [StreamCellItem]) {
        let vc = PostDetailViewController(post: post, items: initialItems)
        vc.currentUser = currentUser
        vc.willPresentStreamable(scrollLogic.isShowing)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
    }
}

// MARK: UserTappedDelegate
extension StreamableViewController: UserTappedDelegate {
    public func userTapped(user: User) {
        if alreadyOnUserProfile(user.userId) {
            return
        }

        let vc = ProfileViewController(userParam: user.userId)
        vc.currentUser = currentUser
        vc.willPresentStreamable(scrollLogic.isShowing)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
    }
}

// MARK: CreateCommentDelegate
extension StreamableViewController: CreateCommentDelegate {
    public func createComment(post : Post) {
        let vc = OmnibarViewController(parentPost: post)
        vc.currentUser = self.currentUser
        vc.onCommentSuccess() { (comment: Comment) in
            self.navigationController?.popViewControllerAnimated(true)
            self.commentCreated(comment)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // child classes should override this method and add the comment to their
    // datasource.
    func commentCreated(comment: Comment) {}
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
