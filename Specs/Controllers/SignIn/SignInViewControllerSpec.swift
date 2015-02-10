//
//  SignInViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello

class SignInViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        var controller = SignInViewController.instantiateFromStoryboard()
        let screenHeight = controller.view.bounds.size.height
        let screenWidth = controller.view.bounds.size.width

        describe("initialization", {

            beforeEach({
                controller = SignInViewController.instantiateFromStoryboard()
            })

            describe("storyboard", {

                beforeEach({
                    controller.loadView()
                    controller.viewDidLoad()
                })

                it("IBOutlets are  not nil", {
                    expect(controller.scrollView).notTo(beNil())
                    expect(controller.enterButton).notTo(beNil())
                    expect(controller.forgotPasswordButton).notTo(beNil())
                    expect(controller.emailTextField).notTo(beNil())
                    expect(controller.passwordTextField).notTo(beNil())
                    expect(controller.createAccountButton).notTo(beNil())
                })

                it("IBActions are wired up", {
                    let enterActions = controller.enterButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)

                    expect(enterActions).to(contain("enterTapped:"))

                    expect(enterActions?.count) == 1

                    let forgotPasswordActions = controller.forgotPasswordButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(forgotPasswordActions).to(contain("forgotPasswordTapped:"))

                    expect(forgotPasswordActions?.count) == 1

                    let createAccountActions = controller.createAccountButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)
                    expect(createAccountActions).to(contain("createAccountTapped:"))

                    expect(createAccountActions?.count) == 1
                });
            })

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a SignInViewController", {
                expect(controller).to(beAKindOf(SignInViewController.self))
            })

        })

        describe("text fields", {

            beforeEach({
                controller = SignInViewController.instantiateFromStoryboard()
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

            context("passwordTextField", {

                it("is properly configured", {
                    expect(controller.passwordTextField.keyboardType.rawValue) == UIKeyboardType.Default.rawValue
                    expect(controller.passwordTextField.returnKeyType.rawValue) == UIReturnKeyType.Go.rawValue
                    expect(controller.passwordTextField.secureTextEntry) == true
                })

                it("has controller as delegate", {
                    expect(controller.passwordTextField.delegate) === controller
                })

            })
        })

        describe("-viewDidLoad", {

            beforeEach({
                controller = SignInViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            it("has a cross dissolve modal transition style", {
                expect(controller.modalTransitionStyle.rawValue) == UIModalTransitionStyle.CrossDissolve.rawValue
            })

            it("has a disabled enter button", {
                expect(controller.enterButton.enabled) == false
            })
        })

        describe("notifications", {

            beforeEach({
                controller = SignInViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            describe("UIKeyboardWillShowNotification", {

                context("keyboard is docked", {

                    it("adjusts scrollview", {

                        let keyboardRect = CGRectMake(0.0, screenHeight - 303.0 , screenWidth, 303.0)
                        let notification = NSNotification(name: UIKeyboardWillShowNotification, object: nil, userInfo: [UIKeyboardFrameEndUserInfoKey : NSValue(CGRect: keyboardRect)])

                        NSNotificationCenter.defaultCenter().postNotification(notification)

                        expect(controller.scrollView.contentInset.bottom) > 50
                    })
                })

                context("keyboard is not docked", {
                    it("does NOT adjust scrollview", {

                        let keyboardRect = CGRectMake(0.0, screenHeight - 100, screenWidth, 303.0)
                        let notification = NSNotification(name: UIKeyboardWillShowNotification, object: nil, userInfo: [UIKeyboardFrameEndUserInfoKey : NSValue(CGRect: keyboardRect)])

                        NSNotificationCenter.defaultCenter().postNotification(notification)

                        expect(controller.scrollView.contentInset.bottom) == 0
                    })
                })
            })

            describe("UIKeyboardWillHideNotification", {

                it("adjusts scrollview", {

                    let keyboardRect = CGRectMake(0.0, screenHeight, screenWidth, 303.0)
                    let notification = NSNotification(name: UIKeyboardWillHideNotification, object: nil, userInfo: [UIKeyboardFrameEndUserInfoKey : NSValue(CGRect: keyboardRect)])

                    NSNotificationCenter.defaultCenter().postNotification(notification)

                    expect(controller.scrollView.contentInset.bottom) == 0
                })
            })
        })
    }
}
