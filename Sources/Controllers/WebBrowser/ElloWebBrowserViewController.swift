//
//  ElloWebBrowserViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/1/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import KINWebBrowser
import SVGKit
import Crashlytics

public class ElloWebBrowserViewController: KINWebBrowserViewController {
    var toolbarHidden = false
    static var currentUser: User?

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as! ElloTabBarController?
    }

    public class func navigationControllerWithBrowser(webBrowser: ElloWebBrowserViewController) -> UINavigationController {
        let xButton = UIBarButtonItem(image: SVGKImage(named: "x_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("doneButtonPressed:"))

        let shareButton = UIBarButtonItem(image: SVGKImage(named: "share_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("actionButtonPressed:"))

        webBrowser.navigationItem.leftBarButtonItem = xButton
        webBrowser.navigationItem.rightBarButtonItem = shareButton
        webBrowser.actionButtonHidden = true

        return UINavigationController(rootViewController: webBrowser)
    }

    override public class func navigationControllerWithWebBrowser() -> UINavigationController {
        let browser = self()
        return navigationControllerWithBrowser(browser)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(toolbarHidden, animated: false)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
        Crashlytics.sharedInstance().setObjectValue("ElloWebBrowser", forKey: CrashlyticsKey.StreamName.rawValue)
        delegate = self
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

}

// MARK: ElloWebBrowserViewConteroller: KINWebBrowserDelegate
extension ElloWebBrowserViewController: KINWebBrowserDelegate {

    public func webBrowser(webBrowser: KINWebBrowserViewController!, shouldStartLoadWithRequest request: NSURLRequest!) -> Bool {
        return !ElloWebViewHelper.handleRequest(request, webLinkDelegate: self)
    }

}

// MARK: ElloWebBrowserViewController : WebLinkDelegate
extension ElloWebBrowserViewController : WebLinkDelegate {
    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .External, .WTF: loadURLString(data)
        case .Profile: showProfile(data)
        case .Post: showPostDetail(data)
        case .Settings: showSettings()
        case .Friends, .Noise: showStreamContainer()
        case .Notifications: showNotifications()
        case .Search, .Discover: showDiscover()
        case .Internal: showInternalWarning()
        }
    }

    private func showProfile(username: String) {
        let param = "~\(username)"
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = ElloWebBrowserViewController.currentUser
            navigationController?.pushViewController(settings, animated: true)
        }
    }

    private func showStreamContainer() {
        elloTabBarController?.selectedTab = .Stream
    }

    private func showNotifications() {
        elloTabBarController?.selectedTab = .Notifications
    }

    private func showDiscover() {
        elloTabBarController?.selectedTab = .Discovery
    }

    private func showInternalWarning() {
        let message = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Initial stream load failure")
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Dark, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
