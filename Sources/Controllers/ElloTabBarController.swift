//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTabBarController: UITabBarController {

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
                controller.currentUser = self.currentUser
            }
            else if let controller = controller as? ElloNavigationController {
                controller.currentUser = self.currentUser
            }
        }
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> ElloTabBarController {
        var controller = storyboard.controllerWithID(.ElloTabBar)
        println("controller: \(controller)")
        return controller as ElloTabBarController
    }
}
