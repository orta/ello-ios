//
//  BaseElloViewControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class BaseElloViewControllerSpec: QuickSpec {
    override func spec() {
        fdescribe("-isRootViewController") {
            it("should return 'true'") {
                let controller = NotificationsViewController()
                let navController = UINavigationController(rootViewController: controller)
                expect(controller.isRootViewController()).to(beTrue())
            }
            it("should return 'false'") {
                let anyController = UIViewController()
                let controller = NotificationsViewController()
                let navController = UINavigationController(rootViewController: anyController)
                navController.pushViewController(controller, animated: false)
                expect(controller.isRootViewController()).to(beFalse())
            }
        }
    }
}