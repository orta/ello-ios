//
//  ProfileViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import UIKit

class ProfileViewController: BaseElloViewController {

    var username: String?

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> ProfileViewController {
        return storyboard.controllerWithID(.Profile) as ProfileViewController
    }
 
}