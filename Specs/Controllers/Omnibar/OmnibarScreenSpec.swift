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


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        describe("OmnibarScreen") {

            var subject : OmnibarScreen!
            var delegate : OmnibarScreenMockDelegate!

            beforeEach {
                let controller = UIViewController()
                subject = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
                delegate = OmnibarScreenMockDelegate()
                subject.delegate = delegate
                controller.view.addSubview(subject)

                self.showController(controller)
            }

            describe("tapping the avatar") {
                it("should push the profile VC on to the navigation controller") {
                    subject.currentUser = User.stub(["id": "1"])
                    subject.profileImageTapped()
                    expect(delegate.didPushController) == true
                }
            }

            describe("setting text") {
                it("should hide the overlay") {
                    subject.text = "text"
                    expect(subject.sayElloOverlay.hidden) == true
                }
                it("should set the text view") {
                    subject.text = "text"
                    expect(subject.textView.text) == "text"
                }
                it("should set the text view with attributed string") {
                    let attrd = NSAttributedString(string: "text")
                    subject.attributedText = attrd
                    expect(subject.textView.attributedText?.string) == attrd.string
                }
            }
            // I thought that using a url to a *local file* would get this spec to
            // work.  but testing on iOS is apparently stuck in the dark ages.
            xdescribe("setting avatar url") {
                it("should set the avatar image") {
                    let avatarURL = NSBundle.mainBundle().URLForResource("specs-avatar", withExtension: "png")
                    expect(avatarURL).toNot(beNil())

                    subject.avatarURL = avatarURL
                    expect(subject.avatarButton.imageForState(UIControlState.Normal)).toEventuallyNot(beNil())
                }
            }
            describe("start editing") {
                beforeEach {
                    subject.startEditingAction()
                }
                it("should hide the overlay") {
                    expect(subject.sayElloOverlay.hidden) == true
                }
                xit("should focus on the text view") {
                    expect(subject.textView.isFirstResponder()) == true
                }
            }
            describe("pressing cancel") {
                beforeEach {
                    subject.text = "text"
                    subject.image = UIImage.imageWithColor(.blackColor())
                    subject.cancelEditingAction()
                }
                it("should resign the keyboard") {
                    expect(subject.textView.isFirstResponder()) == false
                }
            }
            describe("submitting") {
                it("should respond if there is text (no image)") {
                    subject.text = "text"
                    subject.image = nil
                    subject.submitAction()
                    expect(delegate.submitted) == true
                }
                it("should respond if there is an image (no text)") {
                    subject.text = nil
                    subject.image = UIImage.imageWithColor(.blackColor())
                    subject.submitAction()
                    expect(delegate.submitted) == true
                }
                it("should respond if there is text and image") {
                    subject.text = "text"
                    subject.image = UIImage.imageWithColor(.blackColor())
                    subject.submitAction()
                    expect(delegate.submitted) == true
                }
                it("should NOT respond if there is NO text OR image") {
                    subject.text = nil
                    subject.image = nil
                    subject.submitAction()
                    expect(delegate.submitted) == false
                }
            }
            describe("pressing remove image") {
                beforeEach {
                    subject.image = UIImage.imageWithColor(.blackColor())
                    subject.removeButtonAction()
                }
                it("should clear the image") {
                    expect(subject.image).to(beNil())
                }
            }
            describe("pressing add image") {
                beforeEach {
                    subject.addImageAction()
                }
                it("should open an image selector") {
                    expect(delegate.didPresentController) == true
                }
            }
            describe("reporting an error") {
                it("should report an error (NSError)") {
                    subject.reportError("title", error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                    expect(delegate.didPresentController) == true
                }
                it("should report an error (String)") {
                    subject.reportError("title", errorMessage: "error")
                    expect(delegate.didPresentController) == true
                }
            }
            describe("determining post state") {
                describe("if there is text or image") {
                    describe("after initialization") {
                        it("should be false (default)") {
                            expect(subject.canPost()) == false
                        }
                        it("should be true (after setting text and image)") {
                            subject.text = "text"
                            subject.image = UIImage.imageWithColor(.blackColor())
                            expect(subject.canPost()) == true
                        }
                    }
                    describe("after editing") {
                        it("should be false (text only)") {
                            subject.text = "text"
                            subject.image = nil
                            expect(subject.canPost()) == true
                        }
                        it("should be false (image only)") {
                            subject.text = nil
                            subject.image = UIImage.imageWithColor(.blackColor())
                            expect(subject.canPost()) == true
                        }
                        it("should be false (text and image)") {
                            subject.text = "text"
                            subject.image = UIImage.imageWithColor(.blackColor())
                            expect(subject.canPost()) == true
                        }
                        it("should be false empty text or image") {
                            subject.text = ""
                            subject.image = nil
                            expect(subject.canPost()) == false
                        }
                        it("should be false not text or image") {
                            subject.text = nil
                            subject.image = nil
                            expect(subject.canPost()) == false
                        }
                    }
                }
            }

            context("UITextViewDelegate") {

                describe("textViewShouldBeginEditing(_:)") {

                    it("returns true") {
                        expect(subject.textViewShouldBeginEditing(UITextView())) == true
                    }
                }
            }
        }
    }
}
