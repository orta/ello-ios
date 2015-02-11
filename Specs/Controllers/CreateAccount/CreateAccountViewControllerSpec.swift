//
//  CreateAccountViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class CreateAccountViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = CreateAccountViewController.instantiateFromStoryboard()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization", {

            beforeEach({
                controller = CreateAccountViewController.instantiateFromStoryboard()
            })

            describe("storyboard", {

                beforeEach({
                    controller.loadView()
                    controller.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(controller.scrollView).notTo(beNil())
                    expect(controller.emailTextField).notTo(beNil())
                    expect(controller.usernameTextField).notTo(beNil())
                    expect(controller.passwordTextField).notTo(beNil())
                    expect(controller.aboutButton).notTo(beNil())
                    expect(controller.loginButton).notTo(beNil())
                    expect(controller.createAccountButton).notTo(beNil())
                })

                it("IBActions are wired up", {
                    let aboutActions = controller.aboutButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(aboutActions).to(contain("aboutTapped:"))

                    expect(aboutActions?.count) == 1

                    let loginActions = controller.loginButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(loginActions).to(contain("loginTapped:"))

                    expect(loginActions?.count) == 1

                    let createAccountActions = controller.createAccountButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(createAccountActions).to(contain("createAccountTapped:"))

                    expect(createAccountActions?.count) == 1
                });
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a CreateAccountViewController", {
                expect(controller).to(beAKindOf(CreateAccountViewController.self))
            })
        })

        describe("-viewDidLoad:", {

            beforeEach({
                controller = CreateAccountViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            it("disables createAccountButton") {
                expect(controller.createAccountButton.enabled) == false
            }
        })
    }
}
