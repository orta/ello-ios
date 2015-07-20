//
//  NotificationsViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class NotificationsViewControllerSpec: QuickSpec {
    override func spec() {

        var subject = NotificationsViewController()
        describe("NotificationsViewController") {

            beforeEach {
                subject = NotificationsViewController()
            }

            describe("can open notification links") {
                it("can open notifications/posts/12") {
                    let navigationController = UINavigationController(rootViewController: subject)
                    subject.respondToNotification(["posts", "12"])
                    expect(navigationController.childViewControllers.count).toEventually(equal(2))
                }
                it("can open notifications/users/12") {
                    let navigationController = UINavigationController(rootViewController: subject)
                    subject.respondToNotification(["users", "12"])
                    expect(navigationController.childViewControllers.count).toEventually(equal(2))
                }
                it("can handle unknown links") {
                    let navigationController = UINavigationController(rootViewController: subject)
                    subject.respondToNotification(["flibbity", "jibbet"])
                    expect(navigationController.childViewControllers.count) == 1
                }
            }
        }
    }
}
