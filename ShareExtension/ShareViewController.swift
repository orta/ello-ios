//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Sean on 1/27/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import UIKit
import Social
import KeychainAccess
import SwiftyUserDefaults

class ShareViewController: SLComposeServiceViewController {

    private var notSignedInVC: UIAlertController?

    override func presentationAnimationDidFinish() {
        if let content = extensionContext?.inputItems[0] as? NSExtensionItem {
            print(content)
        }
        if AuthToken().isAuthenticated {
            showNotSignedIn()
        }
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        print(ElloKeychain().authToken)
        print(AuthToken().isAuthenticated)
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//        print(Keychain)
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

private extension ShareViewController {
    func showNotSignedIn() {
        notSignedInVC = UIAlertController(title: "Hello", message: "Please login to the Ello app first to use this feature", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in
            if let context = self.extensionContext {
                let error = NSError(domain: "co.ello.Ello", code: 0, userInfo: nil)
                context.cancelRequestWithError(error)
            }
        }

        let elloAction = UIAlertAction(title: "Ello", style: .Default) {
            action in
            if let context = self.extensionContext, let url = NSURL(string: "ello://ello.co") {
                context.openURL(url){ canOpen in
                    print("can open \(canOpen)")
                }
            }
        }


        notSignedInVC?.addAction(cancelAction)
        notSignedInVC?.addAction(elloAction)
        if let notSignedInVC = notSignedInVC {
            presentViewController(notSignedInVC, animated: true) {

            }
        }

    }
}