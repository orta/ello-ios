//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class DiscoverViewController: BaseElloViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class func instantiateFromStoryboard() -> DiscoverViewController {
        let navController = UIStoryboard.storyboardWithId(.Discover) as UINavigationController
        let discoverViewController = navController.topViewController
        return discoverViewController as DiscoverViewController
    }

    // MARK: - IBActions

    @IBAction func importMyContactsTapped(sender: UIButton) {
        displayContactActionSheet()
    }

    // MARK: - Private

    private func displayContactActionSheet() {

        let alertController = UIAlertController(
            title: "Import your contacts fo find your friends on Ello.",
            message: "Ello does not sell user data and never conatcs anyone without your permission.",
            preferredStyle: .ActionSheet)

        let action = UIAlertAction(title: "Import my contacts", style: .Default, handler: askForContactPermission)
        alertController.addAction(action)

        let cancelAction = UIAlertAction(title: "Not now", style: .Cancel) { action in /** no op **/ }
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true) {
            // ...
        }
    }

    private func askForContactPermission(action: UIAlertAction!) {
        // ask for permission to the contacts
        // once granted, show the import screens

        let vc = AddFriendsContainerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

