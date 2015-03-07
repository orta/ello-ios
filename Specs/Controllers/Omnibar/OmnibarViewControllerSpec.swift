//
//  OmnibarViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {

        var controller : OmnibarViewController?

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach() {
                controller = OmnibarViewController()
            }

            it("can be instantiated") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a OmnibarViewController") {
                expect(controller).to(beAKindOf(OmnibarViewController.self))
            }

            it("uses the OmnibarScreen as its view") {
                if let controller = controller {
                    expect(controller.view).to(beAKindOf(OmnibarScreen.self))
                }
                else {
                    fail("No OmnibarViewController")
                }
            }
        }

        describe("setting up the Screen") {
            xit("assigns the currentUser.avatarURL to the screen") {}
        }

        describe("posting content") {
            xit("should ignore empty content") {}
            xit("should post some text") {}
            xit("should post an image") {}
            xit("should post text and image") {}
        }
    }
}