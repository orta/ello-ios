//
//  ProfileViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class ProfileViewController: BaseElloViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> ProfileViewController {
        let controller = storyboard.viewControllerWithID(.Profile)
        return storyboard.viewControllerWithID(.Profile) as ProfileViewController
    }
}
