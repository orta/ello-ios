//
//  SignInViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class SignInViewControllerSpec: QuickSpec {
    override func spec() {

        var controller = SignInViewController.instantiateFromStoryboard()
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
    }
}
