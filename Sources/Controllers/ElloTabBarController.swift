//
//  ElloTabBarController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ElloTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 2
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ElloTabBarController {
        return storyboard.viewControllerWithID(.ElloTabBar) as ElloTabBarController
    }
}
