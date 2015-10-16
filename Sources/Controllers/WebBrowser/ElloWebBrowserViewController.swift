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
    static var elloTabBarController: ElloTabBarController?

    public class func navigationControllerWithBrowser(webBrowser: ElloWebBrowserViewController) -> ElloNavigationController {
        // tell AppDelegate to allow rotation
        AppDelegate.restrictRotation = false
        let xButton = UIBarButtonItem(image: SVGKImage(named: "x_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("doneButtonPressed:"))

        let shareButton = UIBarButtonItem(image: SVGKImage(named: "share_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("actionButtonPressed:"))

        webBrowser.navigationItem.leftBarButtonItem = xButton
        webBrowser.navigationItem.rightBarButtonItem = shareButton
        webBrowser.actionButtonHidden = true

        return ElloNavigationController(rootViewController: webBrowser)
    }

    override public class func navigationControllerWithWebBrowser() -> ElloNavigationController {
        let browser = self.init()
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
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: self, fromWebView: true)
    }

    public func willDismissWebBrowser(webView: KINWebBrowserViewController) {
        AppDelegate.restrictRotation = true
    }

}

// MARK: ElloWebBrowserViewController : WebLinkDelegate
extension ElloWebBrowserViewController : WebLinkDelegate {
    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .BetaPublicProfiles, .Downloads, .Email, .External, .ForgotMyPassword, .Manifesto, .RequestInvite, .RequestInvitation, .Subdomain, .WhoMadeThis, .WTF: break // this is handled in ElloWebViewHelper/KINWebBrowserViewController
        case .Discover: self.selectTab(.Discovery)
        case .Enter, .Exit, .Root: self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        case .Following, .Noise: self.selectTab(.Stream)
        case .Notifications: self.selectTab(.Notifications)
        case .Post: self.showPostDetail(data)
        case .Profile: self.showProfile(data)
        case .Search: showSearch(data)
        case .Settings: self.showSettings()
        }
    }

    private func showProfile(username: String) {
        let param = "~\(username)"
        if alreadyOnUserProfile(param) { return }
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSearch(terms: String) {
        let vc = SearchViewController()
        vc.currentUser = ElloWebBrowserViewController.currentUser
        vc.searchForPosts(terms)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = ElloWebBrowserViewController.currentUser
            navigationController?.pushViewController(settings, animated: true)
        }
    }

    private func selectTab(tab: ElloTab) {
        navigationController?.dismissViewControllerAnimated(true) {
            ElloWebBrowserViewController.elloTabBarController?.selectedTab = tab
        }
    }

    func alreadyOnUserProfile(userParam: String) -> Bool {
        if let profileVC = navigationController?.topViewController as? ProfileViewController {
            return userParam == profileVC.userParam
        }
        return false
    }

    func alreadyOnPostDetail(postParam: String) -> Bool {
        if let postDetailVC = navigationController?.topViewController as? PostDetailViewController {
            return postParam == postDetailVC.postParam
        }
        return false
    }
}
