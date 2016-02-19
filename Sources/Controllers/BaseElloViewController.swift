//
//  BaseElloViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

@objc public protocol ControllerThatMightHaveTheCurrentUser {
    var currentUser: User? { get set }
}

public class BaseElloViewController: UIViewController, ControllerThatMightHaveTheCurrentUser {

    public var elloNavigationItem = UINavigationItem()

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
            return (viewControllers[0] ) == self
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

// MARK: Search
public extension BaseElloViewController {
    func addSearchButton() {
        elloNavigationItem.rightBarButtonItem = UIBarButtonItem(image: InterfaceImage.Search.normalImage, style: .Done, target: self, action: Selector("searchButtonTapped"))
    }

    func searchButtonTapped() {
        let search = SearchViewController()
        search.currentUser = currentUser
        self.navigationController?.pushViewController(search, animated: true)
    }
}
