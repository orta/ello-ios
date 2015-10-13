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
import SwiftyUserDefaults


class OmnibarMockScreen: OmnibarScreenProtocol {
    var delegate: OmnibarScreenDelegate?
    var isEditing: Bool = false
    var title: String = ""
    var avatarURL: NSURL?
    var avatarImage: UIImage?
    var currentUser: User?
    var regions = [OmnibarRegion]() {
        didSet { print("regions: \(regions)")}
    }

    var canGoBack = false
    var didReportSuccess = false
    var didReportError = false
    var didKeyboardWillShow = false
    var didKeyboardWillHide = false

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

    func stopEditing() {
    }

    func updateButtons() {
    }
}


class OmnibarViewControllerSpec: QuickSpec {
    override func spec() {

        var subject: OmnibarViewController!
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
                    subject = OmnibarViewController()
                }

                it("can be instantiated") {
                    subject = OmnibarViewController()
                    expect(subject).notTo(beNil())
                }

                it("can be instantiated with a post") {
                    let post = Post.stub([
                        "author": User.stub(["username": "colinta"])
                        ])
                    subject = OmnibarViewController(parentPost: post)
                    expect(subject).notTo(beNil())
                }

                it("is a BaseElloViewController") {
                    expect(subject).to(beAKindOf(BaseElloViewController.self))
                }

                it("is a OmnibarViewController") {
                    expect(subject).to(beAKindOf(OmnibarViewController.self))
                }
            }

            context("setting up the Screen") {

                beforeEach {
                    subject = OmnibarViewController()
                    screen = OmnibarMockScreen()
                    subject.screen = screen
                    self.showController(subject)
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
                    subject.currentUser = user
                    expect(screen.avatarURL?.absoluteString).to(equal("http://ello.co/avatar.png"))
                }
            }

            context("submitting a post") {
                it("should generate PostEditingService.PostContentType") {
                    let image = UIImage.imageWithColor(UIColor.blackColor())
                    let data = NSData()
                    let contentType = "image/gif"
                    let text = NSAttributedString(string: "test")

                    let regions = [
                        OmnibarRegion.Image(image, nil, nil),
                        OmnibarRegion.Image(image, data, contentType),
                        OmnibarRegion.AttributedText(text),
                        OmnibarRegion.Spacer,
                        OmnibarRegion.ImageURL(NSURL(string: "http://example.com")!),
                    ]

                    subject = OmnibarViewController()
                    let content = subject.generatePostContent(regions)
                    expect(content.count) == 3

                    guard case let PostEditingService.PostContentType.Image(outImage) = content[0] else {
                        fail("content[0] is not PostEditingService.PostContentType.Image")
                        return
                    }
                    expect(outImage == image)

                    guard case let PostEditingService.PostContentType.ImageData(_, outData, outType) = content[1] else {
                        fail("content[1] is not PostEditingService.PostContentType.ImageData")
                        return
                    }
                    expect(outData) == data
                    expect(outType) == contentType

                    guard case let PostEditingService.PostContentType.Text(outText) = content[2] else {
                        fail("content[2] is not PostEditingService.PostContentType.Text")
                        return
                    }
                    expect(outText) == text.string
                }
            }

            context("restoring a comment") {

                beforeEach {
                    let post = Post.stub([
                        "author": User.stub(["username": "colinta"])
                    ])

                    let attributedString = ElloAttributedString.style("text")
                    let image = UIImage.imageWithColor(.blackColor())
                    let omnibarData = OmnibarData()
                    omnibarData.regions = [attributedString, image]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)

                    subject = OmnibarViewController(parentPost: post)
                    if let fileName = subject.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    screen = OmnibarMockScreen()
                    subject.screen = screen
                    subject.beginAppearanceTransition(true, animated: false)
                    subject.endAppearanceTransition()
                }

                afterEach {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should have text set") {
                    checkRegions(screen.regions, equal: "text")
                }

                it("should have image set") {
                    expect(screen).to(haveImageRegion())
                }
            }

            context("saving a comment") {

                beforeEach {
                    let post = Post.stub([
                        "author": User.stub(["username": "colinta"])
                    ])

                    subject = OmnibarViewController(parentPost: post)
                    screen = OmnibarMockScreen()
                    subject.screen = screen
                    subject.beginAppearanceTransition(true, animated: false)
                    subject.endAppearanceTransition()

                    let image = UIImage.imageWithColor(.blackColor())
                    screen.regions = [
                        .Text("text"), .Image(image, nil, nil)
                    ]
                }

                afterEach {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should save the data when cancelled") {
                    expect(Tmp.fileExists(subject.omnibarDataName()!)).to(beFalse())
                    subject.omnibarCancel()
                    expect(Tmp.fileExists(subject.omnibarDataName()!)).to(beTrue())
                }
            }

            context("initialization with default text") {
                let post = Post.stub([:])

                beforeEach {
                    subject = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                }

                afterEach {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }
                }

                it("should have the text in the textView") {
                    checkRegions(subject.screen.regions, contain: "@666 ")
                }

                it("should ignore the saved text when defaultText is given") {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData()
                    omnibarData.regions = [text]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = subject.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    subject = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    checkRegions(subject.screen.regions, contain: "@666 ")
                    checkRegions(subject.screen.regions, notToContain: "testing!")
                }

                it("should not have the text if the tmp text was on another post") {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData()
                    omnibarData.regions = [text]
                    let data = NSData()
                    if let fileName = subject.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    subject = OmnibarViewController(parentPost: Post.stub([:]), defaultText: "@666 ")
                    checkRegions(subject.screen.regions, contain: "@666 ")
                    checkRegions(subject.screen.regions, notToContain: "testing!")
                }
            }

            context("editing a post") {
                let post = Post.stub([:])
                beforeEach {
                    // NB: this post will be *reloaded* using the stubbed json response
                    // so if you wonder where the text comes from, it's from there, not
                    // the stubbed post.
                    subject = OmnibarViewController(editPost: post)
                }

                it("should have the post body in the textView") {
                    checkRegions(subject.screen.regions, contain: "did you say \"mancrush\"")
                }

                it("should have the text if there was tmp text available") {
                    if let fileName = subject.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarData()
                    omnibarData.regions = [text]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = subject.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    subject = OmnibarViewController(editPost: post)
                    checkRegions(subject.screen.regions, notToContain: "testing!")
                }
            }

            context("post editability") {

                beforeEach {
                    Defaults["OmnibarNewEditorEnabled"] = true
                }

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
                it("can edit two text regions") {
                    let regions: [Regionable]? = [
                        TextRegion.stub([:]),
                        TextRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }
                it("can edit two image regions") {
                    let regions: [Regionable]? = [
                        ImageRegion.stub([:]),
                        ImageRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }
                it("can edit a text region followed by an image region") {
                    let regions: [Regionable]? = [
                        TextRegion.stub([:]),
                        ImageRegion.stub([:])
                    ]
                    expect(OmnibarViewController.canEditRegions(regions)) == true
                }
                describe("can edit two text regions and a single image region") {
                    it("text, text, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            TextRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                    it("text, image, text") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                    it("image, text, text") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                }
                describe("can edit two image regions and a single text region") {
                    it("text, image, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            ImageRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                    it("image, text, image") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                    it("image, image, text") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == true
                    }
                }
                describe("cannot edit embed regions") {
                    it("text, embed, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            EmbedRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("embed, image, text") {
                        let regions: [Regionable]? = [
                            EmbedRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("image, text, embed") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            EmbedRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                }
                describe("cannot edit unknown regions") {
                    it("text, unknown, image") {
                        let regions: [Regionable]? = [
                            TextRegion.stub([:]),
                            UnknownRegion.stub([:]),
                            ImageRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("unknown, image, text") {
                        let regions: [Regionable]? = [
                            UnknownRegion.stub([:]),
                            ImageRegion.stub([:]),
                            TextRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                    it("image, text, unknown") {
                        let regions: [Regionable]? = [
                            ImageRegion.stub([:]),
                            TextRegion.stub([:]),
                            UnknownRegion.stub([:])
                        ]
                        expect(OmnibarViewController.canEditRegions(regions)) == false
                    }
                }
            }
        }
    }
}
