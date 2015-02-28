//
//  OmnibarViewController.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit


class OmnibarViewController: BaseElloViewController, OmnibarScreenDelegate {

    override func loadView() {
        self.view = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen : OmnibarScreen {
        return self.view as OmnibarScreen
    }

    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        self.screen.delegate = self

        let center : NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("willShow:"), name: Keyboard.Notifications.KeyboardWillShow, object: nil)
        center.addObserver(self, selector: Selector("willHide:"), name: Keyboard.Notifications.KeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)

        let center : NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @objc
    func willShow(notification : NSNotification) {
        screen.keyboardWillShow()
    }

    @objc
    func willHide(notification : NSNotification) {
        screen.keyboardWillHide()
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        self.screen.avatarURL = self.currentUser?.avatarURL
    }

    func omnibarCanceled() {
    }

    func omnibarSubmitted(text : String) {
        //
    }

    func omnibarPresentPicker(controller : UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }

    func omnibarDismissPicker(controller : UIViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}