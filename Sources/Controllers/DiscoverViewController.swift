//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class DiscoverViewController: BaseElloViewController {
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

        presentViewController(alertController, animated: true, completion: .None)
    }

    private func askForContactPermission(action: UIAlertAction!) {
        AddressBook.getAddressBook { result in
            switch result {
            case let .Success(box):
                let vc = AddFriendsContainerViewController(addressBook: box.unbox)
                self.navigationController?.pushViewController(vc, animated: true)
            case let .Failure(box):
                self.displayAddressBookAlert(box.unbox.rawValue)
                return
            }
        }
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = UIAlertController(
            title: "We were unable to access your address book",
            message: message,
            preferredStyle: .Alert
        )

        let action = UIAlertAction(title: "OK", style: .Default, handler: .None)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: .None)
    }
}

