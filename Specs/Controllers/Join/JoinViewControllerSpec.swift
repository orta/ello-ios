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
                let view = controller.view
            }

            it("IBOutlets are  not nil") {
                expect(controller.scrollView).notTo(beNil())
                expect(controller.emailView).notTo(beNil())
                expect(controller.usernameView).notTo(beNil())
                expect(controller.passwordView).notTo(beNil())
                expect(controller.aboutButton).notTo(beNil())
                expect(controller.loginButton).notTo(beNil())
                expect(controller.joinButton).notTo(beNil())
                expect(controller.termsButton).notTo(beNil())
            }

            it("IBActions are wired up") {
                let aboutActions = controller.aboutButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                expect(aboutActions).to(contain("aboutTapped:"))
                expect(aboutActions?.count) == 1

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
                it("starts with joinButton disabled") {
                    expect(controller.joinButton.enabled) == false
                }
                it("starts with empty messages") {
                    expect(controller.emailView.hasMessage) == false
                    expect(controller.emailView.messageLabel.text ?? "") == ""
                    expect(controller.emailView.hasError) == false
                    expect(controller.emailView.errorLabel.text ?? "") == ""

                    expect(controller.usernameView.hasMessage) == false
                    expect(controller.usernameView.messageLabel.text ?? "") == ""
                    expect(controller.usernameView.hasError) == false
                    expect(controller.usernameView.errorLabel.text ?? "") == ""

                    expect(controller.passwordView.hasMessage) == false
                    expect(controller.passwordView.messageLabel.text ?? "") == ""
                    expect(controller.passwordView.hasError) == false
                    expect(controller.passwordView.errorLabel.text ?? "") == ""
                }
                it("has all the views located sensibly") {
                    // expect(controller.emailView).toBeBelow(130)
                    expect(controller.emailView.frame.minY) > 130
                    expect(controller.usernameView.frame.height) == controller.emailView.frame.height
                    expect(controller.passwordView.frame.height) == controller.emailView.frame.height
                }
            }

        }
    }
}
