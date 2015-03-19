//
//  StreamableViewController.swift
//  Ello
//
//  Created by Colin Gray on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

protocol PostTappedDelegate : NSObjectProtocol {
    func postTapped(post : Post, initialItems: [StreamCellItem])
}

protocol UserTappedDelegate : NSObjectProtocol {
    func userTapped(user : User)
}


class StreamableViewController : BaseElloViewController, PostTappedDelegate, UserTappedDelegate {

    var scrollLogic: ElloScrollLogic!

    override func viewDidLoad() {
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
        if let tabBarController = self.tabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }

    func hideNavBars() {
        if let tabBarController = self.tabBarController {
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

    func postTapped(post: Post, initialItems: [StreamCellItem]) {
        let vc = PostDetailViewController(post: post, items: initialItems)
        vc.currentUser = currentUser
        vc.willPresentStreamable(scrollLogic.isShowing)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
    }

    func userTapped(user: User) {
        if alreadyOnUserProfile(user.userId) {
            return
        }

        let vc = ProfileViewController(userParam: user.userId)
        vc.currentUser = currentUser
        vc.willPresentStreamable(scrollLogic.isShowing)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
    }

    private func alreadyOnUserProfile(userParam: String) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController {
            return userParam == profileVC.userParam
        }
        return false
    }

}


// MARK: StreamableViewController: StreamScrollDelegate
extension StreamableViewController : StreamScrollDelegate {

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