//
//  DeleteAccountConfirmationViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

private enum DeleteAccountState {
    case AskNicely
    case AreYouSure
    case NoTurningBack
}

public class DeleteAccountConfirmationViewController: BaseElloViewController {
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var infoLabel: ElloLabel!
    @IBOutlet public weak var buttonView: UIView!
    @IBOutlet public weak var cancelView: UIView!
    @IBOutlet public weak var cancelLabel: ElloLabel!

    private var state: DeleteAccountState = .AskNicely
    private var timer: NSTimer?
    private var counter = 5

    public init() {
        super.init(nibName: "DeleteAccountConfirmationView", bundle: NSBundle(forClass: DeleteAccountConfirmationViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        updateInterface()
    }

    private func updateInterface() {
        switch state {
        case .AskNicely:
            let title = NSLocalizedString("Delete Account?", comment: "delete account question")
            titleLabel.text = title

        case .AreYouSure:
            let title = NSLocalizedString("Are You Sure?", comment: "are you sure question")
            titleLabel.text = title
            infoLabel.hidden = false

        case .NoTurningBack:
            let title = NSLocalizedString("Your account is in the process of being deleted.", comment: "Your account is in the process of being deleted.")
            titleLabel.text = title
            titleLabel.font = UIFont(descriptor: titleLabel.font.fontDescriptor(), size: 18)
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick"), userInfo: .None, repeats: true)
            infoLabel.hidden = true
            buttonView.hidden = true
            cancelView.hidden = false
        }
    }

    @objc
    private func tick() {
        let text = NSString(format: NSLocalizedString("You will be redirected in %d...", comment: "You will be redirected in ..."), counter) as String
        nextTick {
            self.cancelLabel.setLabelText(text, color: .whiteColor(), alignment: .Center)
            if self.counter-- <= 0 {
                self.deleteAccount()
            }
        }
    }

    private func deleteAccount() {
        timer?.invalidate()
        ElloHUD.showLoadingHud()

        ProfileService().deleteAccount({
            ElloHUD.hideLoadingHud()
            self.dismissViewControllerAnimated(true) {
                postNotification(AuthenticationNotifications.userLoggedOut, ())
            }
            Tracker.sharedTracker.userDeletedAccount()
        }, failure: { _, _ in
            ElloHUD.hideLoadingHud()
        })
    }

    @IBAction func yesButtonTapped() {
        switch state {
        case .AskNicely: state = .AreYouSure
        case .AreYouSure: state = .NoTurningBack
        default: break
        }
        updateInterface()
    }

    @IBAction private func dismiss() {
        timer?.invalidate()
        dismissViewControllerAnimated(true, completion: .None)
    }
}
