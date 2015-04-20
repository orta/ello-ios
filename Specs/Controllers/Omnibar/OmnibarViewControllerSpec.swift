//
//  OmnibarViewControllerSpec.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


@objc
class OmnibarMockScreen : OmnibarScreenProtocol {
    var delegate : OmnibarScreenDelegate?
    var avatarURL : NSURL?
    var text : String?
    var image : UIImage?
    var attributedText : NSAttributedString?

    var hasParentPost = false
    var didReportSuccess = false
    var didReportError = false
    var didKeyboardWillShow = false
    var didKeyboardWillHide = false

    func reportSuccess(title : String) {
        didReportSuccess = true
    }

    func reportError(title : String, error : NSError) {
        didReportError = true
    }

    func reportError(title : String, errorMessage : String) {
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
                controller = OmnibarViewController()
                expect(controller).notTo(beNil())
            }

            it("can be instantiated with a post") {
                let post = Post.stub([
                    "author": User.stub(["username": "colinta"])
                    ])
                controller = OmnibarViewController(parentPost: post)
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

            xit("assigns the currentUser.avatarURL to the screen") {
                let attachment = Attachment.stub([
                    "url": "http://ello.co/avatar.png",
                    "height": 0,
                    "width": 0,
                    "type": "png",
                    "size": 0]
                    )
                let user: User = stub(["avatar": attachment])
                controller.currentUser = user
                // this is crazy, if I inspect these values they are correct.
                // Swift? Optionals?  ug.
                expect(screen.avatarURL).to(equal("http://ello.co/avatar.png"))
            }
        }

        describe("restoring a comment") {

            beforeEach() {
                let post = Post.stub([
                    "author": User.stub(["username": "colinta"])
                ])

                controller = OmnibarViewController(parentPost: post)
                let attributedString = ElloAttributedString.style("text")
                let image = UIImage(named: "specs-avatar")
                let omnibarData = OmnibarData(attributedText: attributedString, image: image)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                screen = OmnibarMockScreen()
                controller.screen = screen
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()
            }

            afterEach() {
                Tmp.remove(controller.omnibarDataName())
                Void()
            }

            it("should have text set") {
                if let attributedText = screen.attributedText {
                    expect(attributedText.string).to(equal("text"))
                }
                else {
                    fail("no attributedText on screen")
                }
            }

            //TODO: look into this failing, @colinta, any ideas?
            xit("should have image set") {
                expect(screen.image).toNot(beNil())
            }
        }


        describe("saving a comment") {

            beforeEach() {
                let post = Post.stub([
                    "author": User.stub(["username": "colinta"])
                    ])

                controller = OmnibarViewController(parentPost: post)
                screen = OmnibarMockScreen()
                controller.screen = screen
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()

                screen.attributedText = ElloAttributedString.style("text")
                screen.image = UIImage(named: "specs-avatar")
            }

            afterEach() {
                Tmp.remove(controller.omnibarDataName())
                Void()
            }

            it("should save the data when cancelled") {
                expect(Tmp.fileExists(controller.omnibarDataName())).to(beFalse())
                controller.omnibarCancel()
                expect(Tmp.fileExists(controller.omnibarDataName())).to(beTrue())
            }
        }
    }
}
