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
                    let omnibarData = OmnibarMultiRegionData()
                    omnibarData.regions = [attributedString, image]
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

                    controller = OmnibarViewController(parentPost: post)
                    screen = OmnibarMockScreen()
                    controller.screen = screen
                    controller.beginAppearanceTransition(true, animated: false)
                    controller.endAppearanceTransition()

                    let image = UIImage.imageWithColor(.blackColor())
                    screen.regions = [
                        .Text("text"), .Image(image, nil, nil)
                    ]
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
                    checkRegions(controller.screen.regions, contain: "@666 ")
                }

                it("should ignore the saved text when defaultText is given") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarMultiRegionData()
                    omnibarData.regions = [text]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: post, defaultText: "@666 ")
                    checkRegions(controller.screen.regions, contain: "@666 ")
                    checkRegions(controller.screen.regions, notToContain: "testing!")
                }

                it("should not have the text if the tmp text was on another post") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarMultiRegionData()
                    omnibarData.regions = [text]
                    let data = NSData()
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(parentPost: Post.stub([:]), defaultText: "@666 ")
                    checkRegions(controller.screen.regions, contain: "@666 ")
                    checkRegions(controller.screen.regions, notToContain: "testing!")
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
                    checkRegions(controller.screen.regions, contain: "did you say \"mancrush\"")
                }

                it("should have the text if there was tmp text available") {
                    if let fileName = controller.omnibarDataName() {
                        Tmp.remove(fileName)
                    }

                    let text = ElloAttributedString.style("testing!")
                    let omnibarData = OmnibarMultiRegionData()
                    omnibarData.regions = [text]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                    if let fileName = controller.omnibarDataName() {
                        Tmp.write(data, to: fileName)
                    }

                    controller = OmnibarViewController(editPost: post)
                    checkRegions(controller.screen.regions, notToContain: "testing!")
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
