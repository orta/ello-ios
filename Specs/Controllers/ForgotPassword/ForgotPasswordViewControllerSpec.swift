//
//  ForgotPasswordViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/4/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class ForgotPasswordViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        var controller = ForgotPasswordViewController.instantiateFromStoryboard()
        let screenHeight = controller.view.bounds.size.height
        let screenWidth = controller.view.bounds.size.width

        describe("initialization", {

            describe("storyboard", {

                beforeEach({
                    controller.loadView()
                    controller.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(controller.scrollView).notTo(beNil())
                    expect(controller.resetPasswordButton).notTo(beNil())
                    expect(controller.emailTextField).notTo(beNil())
                    expect(controller.signInButton).notTo(beNil())
                })

                it("IBActions are wired up", {
                    let resetActions = controller.resetPasswordButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                    
                    expect(resetActions).to(contain("resetPasswordTapped:"))
                    
                    expect(resetActions?.count) == 1
                    
                    let signInActions = controller.signInButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                    
                    expect(signInActions).to(contain("signInTapped:"))
                    
                    expect(signInActions?.count) == 1

                });
            })

            beforeEach({
                controller = ForgotPasswordViewController.instantiateFromStoryboard()
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a ForgotPasswordViewController", {
                expect(controller).to(beAKindOf(ForgotPasswordViewController.self))
            })
        })

        describe("text fields", {

            beforeEach({
                controller = ForgotPasswordViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            context("emailTextField", {

                it("is properly configured", {
                    expect(controller.emailTextField.keyboardType.rawValue) == UIKeyboardType.EmailAddress.rawValue
                    expect(controller.emailTextField.returnKeyType.rawValue) == UIReturnKeyType.Next.rawValue
                })

                it("has controller as delegate", {
                    expect(controller.emailTextField.delegate) === controller
                })

            })

        })

        describe("-viewDidLoad", {

            beforeEach({
                controller = ForgotPasswordViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            it("has a cross dissolve modal transition style", {
                expect(controller.modalTransitionStyle.rawValue) == UIModalTransitionStyle.CrossDissolve.rawValue
            })

            it("has a disabled reset password button", {
                expect(controller.resetPasswordButton.enabled) == false
            })
        })
    }
}

