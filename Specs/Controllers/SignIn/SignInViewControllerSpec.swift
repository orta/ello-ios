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
                })

                it("IBActins are wired up", {
                    expect(controller.enterButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)).to(contain("enterTapped:"))

                    expect(controller.forgotPasswordButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)).to(contain("forgotPasswordTapped:"))
                });
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a SignInViewController", {
                expect(controller).to(beAKindOf(SignInViewController.self))
            })

        })

        describe("-viewDidLoad", {

            beforeEach({
                controller = SignInViewController.instantiateFromStoryboard()
                controller.loadView()
                controller.viewDidLoad()
            })

            it("has a cross disolve modal transition style", {
                expect(controller.modalTransitionStyle.rawValue) == UIModalTransitionStyle.CrossDissolve.rawValue
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
