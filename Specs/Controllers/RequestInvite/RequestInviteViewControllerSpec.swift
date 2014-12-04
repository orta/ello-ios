//
//  RequestInviteViewControllerSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble


class RequestInviteViewControllerSpec: QuickSpec {
    override func spec() {

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        var controller = RequestInviteViewController.instantiateFromStoryboard()
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
                    expect(controller.requestInviteButton).notTo(beNil())
                    expect(controller.emailTextField).notTo(beNil())
                    expect(controller.signInButton).notTo(beNil())
                })

                it("IBActins are wired up", {
                    expect(controller.requestInviteButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)).to(contain("requestInvitTapped:"))

                    expect(controller.signInButton.actionsForTarget(controller, forControlEvent: UIControlEvents.TouchUpInside)).to(contain("signInTapped:"))
                });
            })

            beforeEach({
                controller = RequestInviteViewController.instantiateFromStoryboard()
            })

            it("can be instatiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController", {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            })

            it("is a RequestInviteViewController", {
                expect(controller).to(beAKindOf(RequestInviteViewController.self))
            })
        })
    }
}
