//
//  ImportPromptViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class ImportPromptViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?
    var onboardingData: OnboardingData?

    required public init() {
        super.init(nibName: "ImportPromptViewController", bundle: NSBundle(forClass: ImportPromptViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Onboarding Import Friends Prompt"
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
        let message = NSLocalizedString("Are you sure you want to import your contacts so we can find your friends on Ello?",
            comment: "Import your contacts permission prompt")
        let alertController = AlertViewController(message: message)

        let importMessage = NSLocalizedString("Yes please", comment: "Yes please action")
        let action = AlertAction(title: importMessage, style: .Dark) { action in
            Tracker.sharedTracker.importContactsInitiated()
            self.proceedWithImport()
        }
        alertController.addAction(action)

        let cancelMessage = NSLocalizedString("Skip", comment: "Skip action")
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
        onboardingViewController?.goToController(vc, data: onboardingData)
    }

    private func displayAddressBookAlert(message: String) {
        let alertController = AlertViewController(
            message: "We were unable to access your address book\n\(message)"
        )

        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: .None)
        alertController.addAction(action)

        presentViewController(alertController, animated: true, completion: .None)
    }

}
