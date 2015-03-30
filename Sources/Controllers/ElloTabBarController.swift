//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTabBarController: UITabBarController {

    var currentUser : User?
    var profileResponseConfig: ResponseConfig?

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 2
        modalTransitionStyle = .CrossDissolve
    }

    func setProfileData(currentUser: User, responseConfig: ResponseConfig) {
        self.currentUser = currentUser
        self.profileResponseConfig = responseConfig
        for controller in self.childViewControllers {
            if let controller = controller as? BaseElloViewController {
                controller.currentUser = currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.setProfileData(currentUser, responseConfig: responseConfig)
            }
        }
    }

    class func instantiateFromStoryboard() -> ElloTabBarController {
        return UIStoryboard.storyboardWithId(.ElloTabBar) as! ElloTabBarController
    }
}
