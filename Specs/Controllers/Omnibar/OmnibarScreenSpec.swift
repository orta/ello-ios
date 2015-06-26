//
//  OmnibarScreenSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class OmnibarScreenMockDelegate : OmnibarScreenDelegate {
    var didGoBack = false
    var didPresentController = false
    var didDismissController = false
    var didPushController = false
    var submitted = false

    @objc func omnibarCancel() {
        didGoBack = true
    }
    @objc func omnibarPushController(controller: UIViewController) {
        didPushController = true
    }
    @objc func omnibarPresentController(controller : UIViewController) {
        didPresentController = true
    }
    @objc func omnibarDismissController(controller : UIViewController) {
        didDismissController = true
    }
    @objc func omnibarSubmitted(text: NSAttributedString?, data: NSData, type: String) {
        submitted = true
    }
    @objc func omnibarSubmitted(text : NSAttributedString?, image: UIImage?) {
        submitted = true
    }
    @objc func updatePostState() {
    }
}


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        var screen : OmnibarScreen!
        var delegate : OmnibarScreenMockDelegate!

        beforeEach {
            let controller = UIViewController()
            screen = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
            delegate = OmnibarScreenMockDelegate()
            screen.delegate = delegate
            controller.view.addSubview(screen)

            self.showController(controller)
        }

        describe("tapping the avatar") {
            it("should push the profile VC on to the navigation controller") {
                screen.currentUser = User.stub(["id": "1"])
                screen.profileImageTapped()
                expect(delegate.didPushController) == true
            }
        }

        describe("setting text") {
            it("should hide the overlay") {
                screen.text = "text"
                expect(screen.sayElloOverlay.hidden) == true
            }
            it("should set the text view") {
                screen.text = "text"
                expect(screen.textView.text) == "text"
            }
            it("should set the text view with attributed string") {
                let attrd = NSAttributedString(string: "text")
                screen.attributedText = attrd
                expect(screen.textView.attributedText?.string) == attrd.string
            }
        }
        // I thought that using a url to a *local file* would get this spec to
        // work.  but testing on iOS is apparently stuck in the dark ages.
        xdescribe("setting avatar url") {
            it("should set the avatar image") {
                let avatarURL = NSBundle.mainBundle().URLForResource("specs-avatar", withExtension: "png")
                expect(avatarURL).toNot(beNil())

                screen.avatarURL = avatarURL
                expect(screen.avatarButtonView.imageForState(UIControlState.Normal)).toEventuallyNot(beNil())
            }
        }
        describe("start editing") {
            beforeEach {
                screen.startEditingAction()
            }
            it("should hide the overlay") {
                expect(screen.sayElloOverlay.hidden) == true
            }
            xit("should focus on the text view") {
                expect(screen.textView.isFirstResponder()) == true
            }
        }
        describe("pressing cancel") {
            beforeEach {
                screen.text = "text"
                screen.image = UIImage.imageWithColor(.blackColor())
                screen.cancelEditingAction()
            }
            it("should resign the keyboard") {
                expect(screen.textView.isFirstResponder()) == false
            }
        }
        describe("submitting") {
            it("should respond if there is text (no image)") {
                screen.text = "text"
                screen.image = nil
                screen.submitAction()
                expect(delegate.submitted) == true
            }
            it("should respond if there is an image (no text)") {
                screen.text = nil
                screen.image = UIImage.imageWithColor(.blackColor())
                screen.submitAction()
                expect(delegate.submitted) == true
            }
            it("should respond if there is text and image") {
                screen.text = "text"
                screen.image = UIImage.imageWithColor(.blackColor())
                screen.submitAction()
                expect(delegate.submitted) == true
            }
            it("should NOT respond if there is NO text OR image") {
                screen.text = nil
                screen.image = nil
                screen.submitAction()
                expect(delegate.submitted) == false
            }
        }
        describe("pressing remove image") {
            beforeEach {
                screen.image = UIImage.imageWithColor(.blackColor())
                screen.removeButtonAction()
            }
            it("should clear the image") {
                expect(screen.image).to(beNil())
            }
        }
        describe("pressing add image") {
            beforeEach {
                screen.addImageAction()
            }
            it("should open an image selector") {
                expect(delegate.didPresentController) == true
            }
        }
        describe("reporting an error") {
            it("should report an error (NSError)") {
                screen.reportError("title", error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                expect(delegate.didPresentController) == true
            }
            it("should report an error (String)") {
                screen.reportError("title", errorMessage: "error")
                expect(delegate.didPresentController) == true
            }
        }
        describe("determining post state") {
            describe("if there is text or image") {
                describe("after initialization") {
                    it("should be false (default)") {
                        expect(screen.canPost()) == false
                    }
                    it("should be true (after setting text and image)") {
                        screen.text = "text"
                        screen.image = UIImage.imageWithColor(.blackColor())
                        expect(screen.canPost()) == true
                    }
                }
                describe("after editing") {
                    it("should be false (text only)") {
                        screen.text = "text"
                        screen.image = nil
                        expect(screen.canPost()) == true
                    }
                    it("should be false (image only)") {
                        screen.text = nil
                        screen.image = UIImage.imageWithColor(.blackColor())
                        expect(screen.canPost()) == true
                    }
                    it("should be false (text and image)") {
                        screen.text = "text"
                        screen.image = UIImage.imageWithColor(.blackColor())
                        expect(screen.canPost()) == true
                    }
                    it("should be false empty text or image") {
                        screen.text = ""
                        screen.image = nil
                        expect(screen.canPost()) == false
                    }
                    it("should be false not text or image") {
                        screen.text = nil
                        screen.image = nil
                        expect(screen.canPost()) == false
                    }
                }
            }
        }
    }
}
