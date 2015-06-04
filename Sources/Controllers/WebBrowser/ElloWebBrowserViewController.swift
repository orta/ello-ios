//
//  ElloWebBrowserViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/1/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import KINWebBrowser
import SVGKit

public class ElloWebBrowserViewController: KINWebBrowserViewController {
    var toolbarHidden = false

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(toolbarHidden, animated: false)
    }

    public class func navigationControllerWithBrowser(webBrowser: ElloWebBrowserViewController) -> UINavigationController {
        let xButton = UIBarButtonItem(image: SVGKImage(named: "x_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("doneButtonPressed:"))
        xButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.greyA()], forState: .Normal)

        //let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: webBrowser, action: Selector("actionButtonPressed:"))
        let shareButton = UIBarButtonItem(image: SVGKImage(named: "share_normal.svg").UIImage!, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: Selector("actionButtonPressed:"))
        shareButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.greyA()], forState: .Normal)

        webBrowser.navigationItem.leftBarButtonItem = xButton
        webBrowser.navigationItem.rightBarButtonItem = shareButton
        webBrowser.actionButtonHidden = true

        return UINavigationController(rootViewController: webBrowser)
    }

    override public class func navigationControllerWithWebBrowser() -> UINavigationController {
        let browser = self()
        return navigationControllerWithBrowser(browser)
    }

}
