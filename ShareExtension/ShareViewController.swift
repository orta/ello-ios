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
import Moya
import Alamofire
import MobileCoreServices

public class ShareViewController: SLComposeServiceViewController {

    public var itemPreviews: [ExtensionItemPreview] = []
    private var postService = PostEditingService()
    private lazy var background: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .blackColor()
        view.frame = self.view.frame
        return view
    }()

    public override func presentationAnimationDidFinish() {
        guard checkIfLoggedIn() else {
            return
        }

        processAttachments()

        super.presentationAnimationDidFinish()
    }

    public override func isContentValid() -> Bool {
        return itemPreviews.count > 0
    }

    public override func didSelectPost() {
        showSpinner()
        let content = ShareRegionProcessor().prepContent(contentText, itemPreviews: itemPreviews)
        postContent(content)
    }
}

// MARK: Private
private extension ShareViewController {

    func processAttachments() {
        guard let extensionItem = extensionContext?.inputItems.safeValue(0) as? NSExtensionItem else {
            return
        }

        inBackground {
            let attachmentProcessor = ShareAttachmentProcessor()

            attachmentProcessor.preview(extensionItem) { previews in
                inForeground {
                    self.itemPreviews = previews
                }
            }
        }
    }

    func showSpinner() {
        view.addSubview(background)
        animate {
            self.background.alpha = 0.5
        }
        ElloHUD.showLoadingHudInView(view)
    }

    func postContent(content: [PostEditingService.PostContentRegion]) {
        postService.create(
            content: content,
            success: { post in
//                Tracker.sharedTracker.shareSuccessful()
                self.donePosting()
                self.dismissPostingForm()
            },
            failure: { error, statusCode in
//                Tracker.sharedTracker.shareFailed()
                self.donePosting()
                self.showFailedToPost()
            }
        )
    }

    func donePosting() {
        ElloHUD.hideLoadingHudInView(self.view)
        self.background.removeFromSuperview()
    }

    func dismissPostingForm() {
        self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
    }

    func checkIfLoggedIn() -> Bool {
        if AuthToken().isPasswordBased {
            print("you are logged in")
        }
        else {
            showNotSignedIn()
        }
        return AuthToken().isPasswordBased
    }

    func showFailedToPost() {
        let message = NSLocalizedString("Uh oh, failed to post to Ello.", comment: "Failed to post to Ello")
        let failedVC = AlertViewController(message: message)
        let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Light) {
            action in
            if let context = self.extensionContext {
                let error = NSError(domain: "co.ello.Ello", code: 0, userInfo: nil)
                context.cancelRequestWithError(error)
            }
        }

        let retryAction = AlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: .Dark) {
            action in
            self.didSelectPost()
        }

        failedVC.addAction(retryAction)
        failedVC.addAction(cancelAction)
        self.presentViewController(failedVC, animated: true, completion: nil)
    }

    func showNotSignedIn() {
        let message = NSLocalizedString("Please login to the Ello app first to use this feature.", comment: "Not logged in message.")
        let notSignedInVC = AlertViewController(message: message)
        let cancelAction = AlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .Dark) {
            action in
            if let context = self.extensionContext {
                let error = NSError(domain: "co.ello.Ello", code: 0, userInfo: nil)
                context.cancelRequestWithError(error)
            }
        }

        notSignedInVC.addAction(cancelAction)
        self.presentViewController(notSignedInVC, animated: true, completion: nil)
    }
}
