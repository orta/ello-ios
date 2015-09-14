//
//  JoinViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class JoinViewControllerSpec: QuickSpec {
    override func spec() {

        var controller: JoinViewController!

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach {
                controller = JoinViewController()
            }

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a JoinViewController") {
                expect(controller).to(beAKindOf(JoinViewController.self))
            }
        }

        describe("storyboard") {

            beforeEach {
                controller = JoinViewController()
                _ = controller.view
            }

            it("IBOutlets are  not nil") {
                expect(controller.scrollView).notTo(beNil())
                expect(controller.emailField).notTo(beNil())
                expect(controller.usernameField).notTo(beNil())
                expect(controller.passwordField).notTo(beNil())
                expect(controller.onePasswordButton).notTo(beNil())
                expect(controller.loginButton).notTo(beNil())
                expect(controller.joinButton).notTo(beNil())
                expect(controller.termsButton).notTo(beNil())
            }

            it("IBActions are wired up") {
                let onePasswordActions = controller.onePasswordButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                expect(onePasswordActions).to(contain("findLoginFrom1Password:"))
                expect(onePasswordActions?.count) == 1

                let loginActions = controller.loginButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                expect(loginActions).to(contain("loginTapped:"))
                expect(loginActions?.count) == 1

                let joinActions = controller.joinButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                expect(joinActions).to(contain("joinTapped:"))
                expect(joinActions?.count) == 1
            }
        }

        describe("validation") {

            beforeEach {
                controller = JoinViewController()
                self.showController(controller)
            }

            describe("initial state") {
                it("starts with joinButton enabled") {
                    expect(controller.joinButton.enabled) == true
                }
                it("starts with empty messages") {
                    expect(controller.emailField.text ?? "") == ""
                    expect(controller.usernameField.text ?? "") == ""
                    expect(controller.passwordField.text ?? "") == ""
                }
                it("has all the views located sensibly") {
                    // expect(controller.emailView).toBeBelow(130)
                    expect(controller.emailField.frame.minY) > 130
                    expect(controller.usernameField.frame.height) == controller.emailField.frame.height
                    expect(controller.passwordField.frame.height) == controller.emailField.frame.height
                }
            }

        }
    }
}
