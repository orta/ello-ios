//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTabBarController: UIViewController {
    var selectedIndex: Int

    required override init() {
        super.init(nibName: nil, bundle: nil)
        selectedIndex = 0
    }

    required override init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        selectedIndex = decoder.decodeIntForKey("selectedIndex")
    }

    var currentUser : User? {
        didSet { didSetCurrentUser() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 2
        modalTransitionStyle = .CrossDissolve
    }

    func didSetCurrentUser() {
        for controller in self.childViewControllers {
            if let controller = controller as? BaseElloViewController {
                controller.currentUser = currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.currentUser = currentUser
            }
        }
    }

    class func instantiateFromStoryboard() -> ElloTabBarController {
        return UIStoryboard.storyboardWithId(.ElloTabBar) as! ElloTabBarController
    }
}
