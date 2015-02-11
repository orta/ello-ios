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

    func didSetCurrentUser() {
    }

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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
