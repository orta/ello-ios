//
//  BaseElloViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

@objc public protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

public class BaseElloViewController: UIViewController, ControllerThatMightHaveTheCurrentUser {

    var elloNavigationItem = UINavigationItem()

    override public var title: String? {
        didSet {
            elloNavigationItem.title = title ?? ""
        }
    }

    public var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as! ElloTabBarController?
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.fixNavBarItemPadding()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    func didSetCurrentUser() {}

    public func isRootViewController() -> Bool {
        if let viewControllers = navigationController?.viewControllers {
            return (viewControllers[0] as! UIViewController) == self
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
