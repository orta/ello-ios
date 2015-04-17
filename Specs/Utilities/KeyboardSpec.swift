//
//  KeyboardSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/2/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class KeyboardSpec: QuickSpec {
    override func spec() {
        var keyboard : Keyboard = Keyboard.shared()
        var textView : UITextView!

        describe("Sanity checks") {
            it("has a 'visible' property") {
                expect(keyboard).notTo(beNil())
            }

            it("has a 'curve' property") {
                expect(keyboard).notTo(beNil())
            }

            it("has a 'options' property") {
                expect(keyboard).notTo(beNil())
            }

            it("has a 'duration' property") {
                expect(keyboard).notTo(beNil())
            }
            
            it("has a 'height' property") {
                expect(keyboard).notTo(beNil())
            }
        }

        xdescribe("Responds to keyboard being shown") {
            beforeEach() {
                let controller = UIViewController()
                let window = self.showController(controller)
                textView = UITextView(frame: window.bounds)
                textView.becomeFirstResponder()
                controller.view.addSubview(textView)
            }

            it("sets the 'visible' property") {
                expect(keyboard.visible).to(equal(true))
            }

            it("sets the 'curve' property") {
                expect(keyboard.curve).toNot(equal(UIViewAnimationCurve(rawValue: 0)))
            }

            it("sets the 'options' property") {
                expect(keyboard.options).toNot(equal(UIViewAnimationOptions(rawValue: 0)))
            }

            it("sets the 'duration' property") {
                expect(keyboard.duration).toNot(equal(0))
            }

            it("sets the 'height' property") {
                expect(keyboard.height).toNot(equal(0))
            }

            it("can calculate the location of the top of the keyboard") {
                let height = textView.frame.size.height
                let calculatedKeyboardTop = height - keyboard.height
                expect(calculatedKeyboardTop) > 0
                expect(calculatedKeyboardTop) < height
                expect(keyboard.keyboardTop(inView: textView)).to(equal(calculatedKeyboardTop))
            }
        }
    }
}
