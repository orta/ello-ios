//
//  SettingsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class SettingsViewController: BaseElloViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> SettingsViewController {
        return storyboard.controllerWithID(.Settings) as SettingsViewController
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AccessManager.Notifications.LoggedOut.rawValue, object: nil)
    }

}
