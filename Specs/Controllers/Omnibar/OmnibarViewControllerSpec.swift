//
//  OmnibarViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarMockScreen : OmnibarScreenProtocol {
    var delegate : OmnibarScreenDelegate?
    var avatarURL : NSURL?
    var text : String?
    var image : UIImage?
    var attributedText : NSAttributedString?

    var didReportError = false
    var didKeyboardWillShow = false
    var didKeyboardWillHide = false

    func reportSuccess(title : String) {
    }
    func reportError(title : String, error : NSError) {
        didReportError = true
    }
    func reportError(title : String, error : String) {
        didReportError = true
    }
    func keyboardWillShow() {
        didKeyboardWillShow = true
    }
    func keyboardWillHide() {
        didKeyboardWillHide = true
    }

}


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {

        var controller : OmnibarViewController!
        var screen : OmnibarMockScreen!

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
                expect(controller.view).to(beAKindOf(OmnibarScreen.self))
            }
        }

        describe("setting up the Screen") {
            beforeEach() {
                controller = OmnibarViewController()
                screen = OmnibarMockScreen()
                controller.screen = screen
            }
            it("assigns the currentUser.avatarURL to the screen") {
                let url = NSURL(string: "http://ello.co/avatar.png")
                let user = User.fakeCurrentUser("foo", avatarURL: url)
                controller.currentUser = user
                expect(screen.avatarURL) == url
            }
        }
    }
}