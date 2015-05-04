//
//  ElloWebBrowserViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/1/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import KINWebBrowser

class ElloWebBrowserViewController: KINWebBrowserViewController {
    var toolbarHidden = false

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(toolbarHidden, animated: false)
    }

    class func navigationControllerWithBrowser(webBrowser: ElloWebBrowserViewController) -> UINavigationController {
        let xButton = UIBarButtonItem(title: "\u{2573}", style: .Done, target: webBrowser, action: Selector("doneButtonPressed:"))
        xButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.blackColor()], forState: .Normal)
        webBrowser.navigationItem.rightBarButtonItem = xButton

        return UINavigationController(rootViewController: webBrowser)
    }

    override class func navigationControllerWithWebBrowser() -> UINavigationController {
        let browser = self()
        return navigationControllerWithBrowser(browser)
    }

}
