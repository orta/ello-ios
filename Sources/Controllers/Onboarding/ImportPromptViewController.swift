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
            let message = InterfaceString.Friends.AccessDenied
            displayAddressBookAlert(message)
        case .Restricted:
            let message = InterfaceString.Friends.AccessRestricted
            displayAddressBookAlert(message)
        }
    }

    private func promptForAddressBookAccess() {
        let message = InterfaceString.Friends.ImportPermissionPrompt
        let alertController = AlertViewController(message: message)

        let importMessage = InterfaceString.Friends.ImportAllow
        let action = AlertAction(title: importMessage, style: .Dark) { action in
            Tracker.sharedTracker.importContactsInitiated()
            self.proceedWithImport()
        }
        alertController.addAction(action)

        let cancelMessage = InterfaceString.Skip
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
            message: String(format: InterfaceString.Friends.ImportErrorTemplate, message)
        )

        let action = AlertAction(title: InterfaceString.OK, style: .Dark, handler: .None)
        alertController.addAction(action)

        logPresentingAlert("ImportPromptViewController")
        presentViewController(alertController, animated: true, completion: .None)
    }

}
