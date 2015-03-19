//
//  BaseElloViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class BaseElloViewController: UIViewController {

    var currentUser : User? {
        didSet { didSetCurrentUser() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fixNavBarItemPadding()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    func didSetCurrentUser() {}

    private func fixNavBarItemPadding() {
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -22
        if let rightBarButtonItems = self.navigationItem.rightBarButtonItems {
            self.navigationItem.rightBarButtonItems = [negativeSpacer] + rightBarButtonItems
        }

        if let leftBarButtonItems = self.navigationItem.leftBarButtonItems {
            self.navigationItem.leftBarButtonItems = [negativeSpacer] + leftBarButtonItems
        }

    }

    func isRootViewController() -> Bool {
        if let viewControllers = navigationController?.viewControllers {
            return (viewControllers[0] as UIViewController) == self
        }
        return false
    }

    func alreadyOnUserProfile(userParam: String) -> Bool {
        if let profileVC = self.navigationController?.topViewController as? ProfileViewController {
            return userParam == profileVC.userParam
        }
        return false
    }

    func alreadyOnPostDetail(postParam: String) -> Bool {
        if let postDetailVC = self.navigationController?.topViewController as? PostDetailViewController {
            return postParam == postDetailVC.postParam
        }
        return false
    }
}
