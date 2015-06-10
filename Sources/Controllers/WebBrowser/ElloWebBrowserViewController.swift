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
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

}
