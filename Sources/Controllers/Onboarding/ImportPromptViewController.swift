//
//  ImportPromptViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ImportPromptViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?

    required public init() {
        super.init(nibName: "ImportPromptViewController", bundle: NSBundle(forClass: ImportPromptViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}


// MARK: IBActions
extension ImportPromptViewController {
    @IBAction
    public func importContactsTapped() {
        initiateImport()
    }
}


// MARK: Importing
extension ImportPromptViewController {

    private func initiateImport() {
        Tracker.sharedTracker.inviteFriendsTapped()
        switch AddressBook.authenticationStatus() {
        case .Authorized:
            proceedWithImport()
        case .NotDetermined:
            promptForAddressBookAccess()
        case .Denied:
            let message = NSLocalizedString("Access to your contacts has been denied.  If you want to search for friends, you will need to grant access from Settings.",
                comment: "Access to contacts denied by user")
            displayAddressBookAlert(message)
        case .Restricted:
            let message = NSLocalizedString("Access to your contacts has been denied by the system.",
                comment: "Access to contacts denied by system")
            displayAddressBookAlert(message)
        }
    }

    private func promptForAddressBookAccess() {
        let message = NSLocalizedString("Import your contacts fo find your friends on Ello.\n\nEllo does not sell user data and never contacts anyone without your permission.",
            comment: "Import your contacts permission prompt")
        let alertController = AlertViewController(message: message)

        let importMessage = NSLocalizedString("Import my contacts", comment: "Import my contacts action")
        let action = AlertAction(title: importMessage, style: .Dark) { action in
            Tracker.sharedTracker.importContactsInitiated()
            self.proceedWithImport()
        }
        alertController.addAction(action)

        let cancelMessage = NSLocalizedString("Not now", comment: "Not now action")
        let cancelAction = AlertAction(title: cancelMessage, style: .Light) { _ in
            Tracker.sharedTracker.importContactsDenied()
        }
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: .None)
    }

    private func proceedWithImport() {
        Tracker.sharedTracker.addressBookAccessed()
        AddressBook.getAddressBook { result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case let .Success(box):
                    self.goToFindFriends(addressBook: box.value)
                case let .Failure(box):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(false)
                    self.displayAddressBookAlert(box.value.rawValue)
                }
            }
        }
    }

    private func goToFindFriends(#addressBook: ContactList) {
        Tracker.sharedTracker.contactAccessPreferenceChanged(true)
        let vc = ImportFriendsViewController(addressBook: addressBook)
        vc.onboardingViewController = onboardingViewController
        vc.currentUser = currentUser
        onboardingViewController?.goToController(vc)
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = AlertViewController(
            message: "We were unable to access your address book\n\(message)"
        )

        let action = AlertAction(title: "OK", style: .Dark, handler: .None)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: .None)
    }

}
