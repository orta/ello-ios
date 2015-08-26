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
    var isEditing: Bool = false
    var title: String = ""
    var avatarURL: NSURL?
    var avatarImage: UIImage?
    var currentUser: User?
    var text: String?
    var image: UIImage?
    var imageURL: NSURL?
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

        describe("OmnibarViewController") {

            context("initialization") {

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

            context("setting up the Screen") {

                beforeEach {
                    controller = OmnibarViewController()
                    screen = OmnibarMockScreen()
                    controller.screen = screen
                    self.showController(controller)
                }

                it("assigns the currentUser.avatarURL to the screen") {
                    let attachment = Attachment.stub([
                        "url": "http://ello.co/avatar.png",
                        "height": 0,
                        "width": 0,
                        "type": "png",
                        "size": 0]
                        )
                    let asset = Asset.stub(["attachment": attachment])
                    let user: User = stub(["avatar": asset])
                    controller.currentUser = user
                    expect(screen.avatarURL?.absoluteString).to(equal("http://ello.co/avatar.png"))
                }
            }

            context("restoring a comment") {

                beforeEach {
                    let post = Post.stub([
                        "author": User.stub(["username": "colinta"])
                    ])

                    let attributedString = ElloAttributedString.style("text")
                    let image = UIImage.imageWithColor(.blackColor())
                    let omnibarData = OmnibarData(attributedText: attributedString, image: image)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)

                    controller = OmnibarViewController(parentPost: post)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    screen = OmnibarMockScreen()
                    controller.screen = screen
                    controller.beginAppearanceTransition(true, animated: false)
                    controller.endAppearanceTransition()
                }

                afterEach {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should have text set") {
                    expect(screen.attributedText?.string ?? "").to(equal("text"))
                }

                it("should have image set") {
                    expect(screen.image).toNot(beNil())
                }
            }

            context("saving a comment") {

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
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should save the data when cancelled") {
                    expect(Tmp.fileExists(controller.omnibarDataName()!)).to(beFalse())
                    controller.omnibarCancel()
                    expect(Tmp.fileExists(controller.omnibarDataName()!)).to(beTrue())
                }
            }

            context("initialization with default text") {
                var post = Post.stub([:])

                beforeEach {
                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                }

                afterEach {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should have the text in the textView") {
                    expect(controller.screen.text).to(contain("@666 "))
                }

                it("should have the text if there was tmp text available") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    expect(controller.screen.text).to(contain("@666 "))
                    expect(controller.screen.text).to(contain("testing!"))
                }

                it("should not have the text if the tmp text was on another post") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: Post.stub([:]), defaultText: "@666 ")
                    expect(controller.screen.text).to(contain("@666 "))
                    expect(controller.screen.text).notTo(contain("testing!"))
                }

                it("should have the text only once") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("@666 testing!")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    expect(controller.screen.text).to(contain("@666 "))
                    expect(controller.screen.text).notTo(contain("@666 @666 "))
                    expect(controller.screen.text).to(contain("testing!"))
                }

                it("should have the text only once, even with whitespace annoyances") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("@666")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    expect(controller.screen.text).to(contain("@666"))
                    expect(controller.screen.text).notTo(contain("@666 @666 "))
                }

                it("should add the text when the username doesn't quite match (@666 @6666)") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("@6666 ")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    expect(controller.screen.text).to(contain("@666 "))
                    expect(controller.screen.text).to(contain("@6666 "))
                }
            }

            context("editing a post") {
                var post = Post.stub([:])
                beforeEach {
                    // NB: this post will be *reloaded* using the stubbed json response
                    // so if you wonder where the text comes from, it's from there, not
                    // the stubbed post.
                    controller = OmnibarViewController(editPost: post)
                }

                it("should have the post body in the textView") {
                    expect(controller.screen.text).to(contain("did you say \"mancrush\""))
                }

                it("should have the text if there was tmp text available") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData(attributedText: text, image: nil)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(editPost: post)
                    expect(controller.screen.text).notTo(contain("testing!"))
                }

            }

            context("post editability") {
                it("can edit a single text region") {
                    let regions: [Regionable]? = [
                        TextRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }
                it("can edit a single image region") {
                    let regions: [Regionable]? = [
                        ImageRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }
                it("can edit an image region followed by a text region") {
                    let regions: [Regionable]? = [
                        ImageRegion.stub([:]),
                        TextRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }

                it("cannot edit zero regions") {
                    let regions: [Regionable]? = [Regionable]()
                    expect(OmnibarViewController.canEditRegions(regions)) == false
                }
                it("cannot edit nil") {
                    let regions: [Regionable]? = nil
                    expect(OmnibarViewController.canEditRegions(regions)) == false
                }
                it("cannot edit two text regions") {
                    let regions: [Regionable]? = [
                        TextRegion.stub([:]),
                        TextRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == false
                }
                it("cannot edit two image regions") {
                    let regions: [Regionable]? = [
                        ImageRegion.stub([:]),
                        ImageRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == false
                }
                it("cannot edit a text region followed by an image region") {
                    let regions: [Regionable]? = [
                        TextRegion.stub([:]),
                        ImageRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == false
                }
                describe("cannot edit two text regions and a single image region") {
                    it("text, text, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            TextRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("text, image, text") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("image, text, text") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                }
                describe("cannot edit two image regions and a single text region") {
                    it("text, image, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            ImageRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("image, text, image") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("image, image, text") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                }
            }
        }
    }
}
