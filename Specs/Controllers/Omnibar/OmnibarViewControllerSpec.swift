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
class OmnibarMockScreen: OmnibarScreenProtocol {
    var delegate: OmnibarScreenDelegate?
    var title: String = ""
    var avatarURL: NSURL?
    var avatarImage: UIImage?
    var currentUser: User?
    var text: String?
    var image: UIImage?
    var attributedText: NSAttributedString?

    var canGoBack = false
    var didReportSuccess = false
    var didReportError = false
    var didKeyboardWillShow = false
    var didKeyboardWillHide = false

    func appendAttributedText(text: NSAttributedString) {
        let mutableString = NSMutableAttributedString()
        if let attributedText = attributedText {
            mutableString.appendAttributedString(attributedText)
        }
        mutableString.appendAttributedString(text)
        attributedText = mutableString
    }

    func reportSuccess(title: String) {
        didReportSuccess = true
    }

    func reportError(title: String, error: NSError) {
        didReportError = true
    }

    func reportError(title: String, errorMessage: String) {
        didReportError = true
    }

    func keyboardWillShow() {
        didKeyboardWillShow = true
    }

    func keyboardWillHide() {
        didKeyboardWillHide = true
    }

    func startEditing() {
    }

    func updatePostState() {
    }
}


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {

        var controller: OmnibarViewController!
        var screen: OmnibarMockScreen!

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {

            beforeEach {
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

            beforeEach {
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

            beforeEach {
                let post = Post.stub([
                    "author": User.stub(["username": "colinta"])
                ])

                let attributedString = ElloAttributedString.style("text")
                let image = UIImage.imageWithColor(.blackColor())
                let omnibarData = OmnibarData(attributedText: attributedString, image: image)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)

                controller = OmnibarViewController(parentPost: post)
                Tmp.write(data, to: controller.omnibarDataName())

                screen = OmnibarMockScreen()
                controller.screen = screen
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()
            }

            afterEach {
                Tmp.remove(controller.omnibarDataName())
            }

            it("should have text set") {
                expect(screen.attributedText?.string ?? "").to(equal("text"))
            }

            it("should have image set") {
                expect(screen.image).toNot(beNil())
            }
        }

        describe("saving a comment") {

            beforeEach {
                let post = Post.stub([
                    "author": User.stub(["username": "colinta"])
                    ])

                controller = OmnibarViewController(parentPost: post)
                screen = OmnibarMockScreen()
                controller.screen = screen
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()

                screen.attributedText = ElloAttributedString.style("text")
                screen.image = UIImage.imageWithColor(.blackColor())
            }

            afterEach {
                Tmp.remove(controller.omnibarDataName())
            }

            it("should save the data when cancelled") {
                expect(Tmp.fileExists(controller.omnibarDataName())).to(beFalse())
                controller.omnibarCancel()
                expect(Tmp.fileExists(controller.omnibarDataName())).to(beTrue())
            }
        }

        describe("initialization with default text") {
            var post = Post.stub([:])

            beforeEach {
                controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
            }

            afterEach {
                Tmp.remove(controller.omnibarDataName())
            }

            it("should have the text in the textView") {
                expect(controller.screen.text).to(contain("@666 "))
            }

            it("should have the text if there was tmp text available") {
                Tmp.remove(controller.omnibarDataName())

                let text = ElloAttributedString.style("testing!")
                let omnibarData = OmnibarData(attributedText: text, image: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                expect(controller.screen.text).to(contain("@666 "))
                expect(controller.screen.text).to(contain("testing!"))
            }

            it("should not have the text if the tmp text was on another post") {
                Tmp.remove(controller.omnibarDataName())

                let text = ElloAttributedString.style("testing!")
                let omnibarData = OmnibarData(attributedText: text, image: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                controller = OmnibarViewController(parentPost: Post.stub([:]), defaultText: "@666 ")
                expect(controller.screen.text).to(contain("@666 "))
                expect(controller.screen.text).notTo(contain("testing!"))
            }

            it("should have the text only once") {
                Tmp.remove(controller.omnibarDataName())

                let text = ElloAttributedString.style("@666 testing!")
                let omnibarData = OmnibarData(attributedText: text, image: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                expect(controller.screen.text).to(contain("@666 "))
                expect(controller.screen.text).notTo(contain("@666 @666 "))
                expect(controller.screen.text).to(contain("testing!"))
            }

            it("should have the text only once, even with whitespace annoyances") {
                Tmp.remove(controller.omnibarDataName())

                let text = ElloAttributedString.style("@666")
                let omnibarData = OmnibarData(attributedText: text, image: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                expect(controller.screen.text).to(contain("@666"))
                expect(controller.screen.text).notTo(contain("@666 @666 "))
            }

            it("should add the text when the username doesn't quite match (@666 @6666)") {
                Tmp.remove(controller.omnibarDataName())

                let text = ElloAttributedString.style("@6666 ")
                let omnibarData = OmnibarData(attributedText: text, image: nil)
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: controller.omnibarDataName())

                controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                expect(controller.screen.text).to(contain("@666 "))
                expect(controller.screen.text).to(contain("@6666 "))
            }

        }

    }
}
