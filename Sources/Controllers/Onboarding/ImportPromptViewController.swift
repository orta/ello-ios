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

    func onboardingWillProceed(_: (OnboardingData?) -> Void) {
        print("implemented but intentionally left blank")
    }

    func onboardingStepBegin() {
        print("implemented but intentionally left blank")
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
        let message = NSLocalizedString("Find your friends on Ello using your contacts.\n\nEllo does not sell user data, and never contacts anyone without your permission.",
            comment: "Use address book permission prompt")
        let alertController = AlertViewController(message: message)

        let importMessage = NSLocalizedString("Find my friends", comment: "Find my friends action")
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

        logPresentingAlert("ImportPromptViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }

    private func proceedWithImport() {
        Tracker.sharedTracker.addressBookAccessed()
        AddressBook.getAddressBook { result in
            nextTick {
                switch result {
                case let .Success(addressBook):
                    self.goToFindFriends(addressBook: addressBook)
                case let .Failure(addressBookError):
                    Tracker.sharedTracker.contactAccessPreferenceChanged(false)
                    self.displayAddressBookAlert(addressBookError.rawValue)
                }
            }
        }
    }

    private func goToFindFriends(addressBook addressBook: ContactList) {
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

        logPresentingAlert("ImportPromptViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }

}
