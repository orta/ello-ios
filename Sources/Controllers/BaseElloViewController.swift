//
//  BaseElloViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class BaseElloViewController: UIViewController {

    var currentUser : User? {
        didSet { didSetCurrentUser() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fixNavBarItemPadding()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated : Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    func didSetCurrentUser() {}

    private func fixNavBarItemPadding() {
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -22
        if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
            self.navigationItem.rightBarButtonItems = [negativeSpacer, rightBarButtonItem]
        }

        if let leftBarButtonItem = self.navigationItem.leftBarButtonItem {
            self.navigationItem.leftBarButtonItems = [negativeSpacer, leftBarButtonItem]
        }

    }

}
