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

struct ExtensionItemPreview {
    let image: UIImage?
    let link: String?
}

public class ShareViewController: SLComposeServiceViewController {

    private var itemPreviews: [ExtensionItemPreview] = []
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

        // Only interested in the first item
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        // Extract content
        previewFromExtensionItem(extensionItem) {
            previews in
            nextTick {
                self.itemPreviews = previews
            }
        }
        super.presentationAnimationDidFinish()

    }

    public override func isContentValid() -> Bool {
        
        return true
    }

    private func previewFromExtensionItem(extensionItem: NSExtensionItem, callback: [ExtensionItemPreview] -> Void) {
        inBackground {
            var previews: [ExtensionItemPreview] = []

            let attachmentCount = extensionItem.attachments?.count ?? 0
            let attachmentProcessed = after(attachmentCount) {
                callback(previews)
            }

            for attachment in extensionItem.attachments as! [NSItemProvider] {
                if attachment.isText() {
                    attachment.loadText(nil) {
                        (item, error) in
                        if let item = item as? String {
                            previews.append(ExtensionItemPreview(image: nil, link: item))
                        }
                        attachmentProcessed()
                    }
                }
                else if attachment.isURL() {
                    var link: String?
                    var preview: UIImage?

                    let urlAndPreviewLoaded = after(2) {
                        previews.append(ExtensionItemPreview(image: preview, link: link))
                        attachmentProcessed()
                    }

                    attachment.loadURL(nil) {
                        (item, error) in
                        if let item = item as? NSURL {
                            link = item.absoluteString
                        }
                        urlAndPreviewLoaded()
                    }
                    
                    attachment.loadPreview(nil) {
                        (image, error) in
                        preview = image as? UIImage
                        urlAndPreviewLoaded()
                    }
                }
                else if attachment.isImage() {
                    attachment.loadImage(nil) {
                        (image, error) in
                        if let imagePath = image as? NSURL,
                            let data = NSData(contentsOfURL: imagePath),
                            let image = UIImage(data: data)
                        {
                            image.copyWithCorrectOrientationAndSize() { image in
                                previews.append(ExtensionItemPreview(image: image, link: nil))
                                attachmentProcessed()
                            }
                        }
                        else {
                            attachmentProcessed()
                        }
                    }
                }
                else { // we don't support this type, move on
                    attachmentProcessed()
                }
            }
        }
    }

    public override func didSelectPost() {
        showSpinner()
        let content = prepContent()
        postContent(content)
    }
}



private extension ShareViewController {

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
                print("Successfully posted from the share controller")
                //TODO: make sure to track success
                self.donePosting()
                self.dismissPostingForm()
            },
            failure: { error, statusCode in
                print("Failed to post from the share controller")
                //TODO: make sure to track failure
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

    func prepContent() -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []

        let cleanedText = contentText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if cleanedText.characters.count > 0 {
            content.append(.Text(cleanedText))
        }
        for preview in itemPreviews {
            if let image = preview.image {
                content.append(.ImageData(image, nil, nil))
            }
            if let text = preview.link {
                content.append(.Text(text))
            }
        }

        return content
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