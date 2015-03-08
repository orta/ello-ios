//
//  OmnibarScreenSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarScreenMockDelegate : OmnibarScreenDelegate {
    var didPresentController = false
    var didDismissController = false
    var submitted = false

    func omnibarPresentController(controller : UIViewController) {
        didPresentController = true
    }
    func omnibarDismissController(controller : UIViewController) {
        didDismissController = true
    }
    func omnibarSubmitted(text : NSAttributedString?, image: UIImage?) {
        submitted = true
    }
}


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        var screen : OmnibarScreen!
        var delegate : OmnibarScreenMockDelegate!

        beforeEach {
            screen = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
            delegate = OmnibarScreenMockDelegate()
            screen.delegate = delegate

            let window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window.makeKeyAndVisible()
            window.addSubview(screen)
        }

        fdescribe("setting text") {
            it("should hide the overlay") {
                screen.text = "text"
                expect(screen.sayElloOverlay.hidden) == false
            }
            it("should set the text view") {
                screen.text = "text"
                expect(screen.textView.text) == "text"
            }
            it("should set the text view with attributed string") {
                let attrd = NSAttributedString(string: "text")
                screen.attributedText = attrd
                expect(screen.textView.attributedText) == attrd
            }
        }
        fdescribe("setting avatar url") {
            it("should set the avatar image") {
                let avatarURL = NSBundle.mainBundle().URLForResource("specs-avatar", withExtension: "png")
                screen.avatarURL = avatarURL
                expect(screen.avatarView.image).toEventuallyNot(beNil())
            }
        }
        fdescribe("start editing") {
            beforeEach {
                screen.startEditingAction()
            }
            it("should hide the overlay") {
                expect(screen.sayElloOverlay.hidden) == true
            }
            it("should focus on the text view") {
                expect(screen.textView.isFirstResponder) == true
            }
        }
        fdescribe("pressing cancel") {
            beforeEach {
                screen.text = "text"
                screen.image = UIImage(named: "specs-avatar")
                screen.cancelEditingAction()
            }
            it("should clear the text") {
                expect(screen.text).to(beNil())
            }
            it("should clear the text view") {
                expect(screen.textView.text) == ""
            }
            it("should clear the image") {
                expect(screen.image).to(beNil())
            }
            it("should clear the image view") {
                expect(screen.imageSelectedButton.currentImage) == nil
            }
            it("should show the overlay") {
                expect(screen.sayElloOverlay.hidden) == false
            }
            it("should resign the keyboard") {
                expect(screen.textView.isFirstResponder) == false
            }
            it("should be undoable") {
                expect(screen.canUndo()) == true
            }
        }
        fdescribe("pressing undo") {
            beforeEach {
                screen.text = "text"
                screen.image = UIImage(named: "specs-avatar")
                screen.cancelEditingAction()
                screen.undoCancelAction()
            }
            it("should assign the text") {
                expect(screen.text) == "text"
            }
            it("should assign the image") {
                expect(screen.image) == UIImage(named: "specs-avatar")
            }
            it("should hide the overlay") {
                expect(screen.sayElloOverlay.hidden) == true
            }
            it("should not be undoable") {
                expect(screen.canUndo()) == false
            }
        }
        fdescribe("submitting") {
            it("should respond if there is text (no image)") {
                screen.text = "text"
                screen.image = nil
                screen.submitAction()
                expect(delegate.submitted) == true
            }
            it("should respond if there is an image (no text)") {
                screen.text = nil
                screen.image = UIImage(named: "specs-avatar")
                screen.submitAction()
                expect(delegate.submitted) == true
            }
            it("should respond if there is text and image") {
                screen.text = "text"
                screen.image = UIImage(named: "specs-avatar")
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
        fdescribe("pressing remove image") {
            beforeEach {
                screen.image = UIImage(named: "specs-avatar")
                screen.removeButtonAction()
            }
            it("should clear the image") {
                expect(screen.image).to(beNil())
            }
        }
        fdescribe("pressing add image") {
            beforeEach {
                screen.addImageAction()
            }
            it("should open an image selector") {
                expect(delegate.didPresentController) == true
            }
        }
        fdescribe("reporting an error") {
            it("should report an error (NSError)") {
                screen.reportError("title", error: NSError())
                expect(delegate.didPresentController) == true
            }
            it("should report an error (String)") {
                screen.reportError("title", error: "error")
                expect(delegate.didPresentController) == true
            }
        }
        fdescribe("determining undo state") {
            fdescribe("if there is text or image") {
                fdescribe("after initialization") {
                    it("should be false (default)") {
                        expect(screen.canUndo()) == false
                    }
                    it("should be false (after setting text and image)") {
                        screen.text = "text"
                        screen.image = UIImage(named: "specs-avatar")
                        expect(screen.canUndo()) == false
                    }
                }
                fdescribe("after canceling") {
                    it("should be true (text only)") {
                        screen.text = "text"
                        screen.image = nil
                        expect(screen.canUndo()) == false
                        screen.cancelEditingAction()
                        expect(screen.canUndo()) == true
                    }
                    it("should be true (image only)") {
                        screen.text = nil
                        screen.image = UIImage(named: "specs-avatar")
                        expect(screen.canUndo()) == false
                        screen.cancelEditingAction()
                        expect(screen.canUndo()) == true
                    }
                    it("should be true (text and image)") {
                        screen.text = "text"
                        screen.image = UIImage(named: "specs-avatar")
                        expect(screen.canUndo()) == false
                        screen.cancelEditingAction()
                        expect(screen.canUndo()) == true
                    }
                    it("should be false not text or image") {
                        screen.text = nil
                        screen.image = nil
                        expect(screen.canUndo()) == false
                        screen.cancelEditingAction()
                        expect(screen.canUndo()) == false
                    }
                }
            }
        }
    }
}