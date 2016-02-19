//
//  DeleteAccountConfirmationViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private enum DeleteAccountState {
    case AskNicely
    case AreYouSure
    case NoTurningBack
}

public class DeleteAccountConfirmationViewController: BaseElloViewController {
    @IBOutlet public weak var titleLabel: UILabel!
    public weak var infoLabel: ElloLabel!
    @IBOutlet public weak var buttonView: UIView!
    @IBOutlet public weak var cancelView: UIView!
    public weak var cancelLabel: ElloLabel!

    private var state: DeleteAccountState = .AskNicely
    private var timer: NSTimer?
    private var counter = 5

    public init() {
        super.init(nibName: "DeleteAccountConfirmationView", bundle: NSBundle(forClass: DeleteAccountConfirmationViewController.self))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        updateInterface()
    }

    private func updateInterface() {
        switch state {
        case .AskNicely:
            let title = InterfaceString.Settings.DeleteAccountConfirm
            titleLabel.text = title

        case .AreYouSure:
            let title = InterfaceString.AreYouSure
            titleLabel.text = title
            infoLabel.hidden = false

        case .NoTurningBack:
            let title = InterfaceString.Settings.AccountIsBeingDeleted
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
        let text = NSString(format: InterfaceString.Settings.RedirectedCountdownTemplate, counter) as String
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

        ProfileService().deleteAccount(success: {
            ElloHUD.hideLoadingHud()
            self.dismissViewControllerAnimated(true) {
                postNotification(AuthenticationNotifications.userLoggedOut, value: ())
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
