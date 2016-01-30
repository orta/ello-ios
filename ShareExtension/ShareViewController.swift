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

// Supress the log() call in AuthToken
func log(message: String) {}


public func url(route: TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}

public class ShareViewController: SLComposeServiceViewController {

    private var notSignedInVC: UIAlertController?
    private var provider: MoyaProvider<ShareAPI>!
    public override func presentationAnimationDidFinish() {

        if !AuthToken().isPasswordBased {
            showNotSignedIn()
        }
        print(ElloURI.baseURL)
        let endpointClosure = { (target: ShareAPI) -> Endpoint<ShareAPI> in
            return Endpoint<ShareAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        }

        provider = MoyaProvider(endpointClosure: endpointClosure)

        provider.request(.Auth(email: "seancdougherty@gmail.com", password: "12345678")) { result in
            // do something with the result
            print(result)
        }
    }

    public override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    public override func didSelectPost() {
        print(ElloKeychain().authToken)
        print(AuthToken().isPasswordBased)




        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    public override func configurationItems() -> [AnyObject]! {
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