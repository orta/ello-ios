//
//  OmnibarScreenSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        describe("setting text") {
            xit("should hide the overlay") {}
            xit("should set the text view") {}
        }
        describe("setting avatar url") {
            xit("should set the avatar image") {
                let avatarURL = NSBundle.mainBundle().URLForResource("specs-avatar", withExtension: "png")
            }
        }
        describe("start editing") {
            xit("should hide the overlay") {}
            xit("should focus on the text view") {}
        }
        describe("pressing cancel") {
            xit("should clear the text view") {}
            xit("should clear the image") {}
            xit("should show the overlay") {}
            xit("should resign the keyboard") {}
            xit("should be undoable") {}
        }
        describe("pressing undo") {
            xit("should assign the text") {}
            xit("should assign the image") {}
            xit("should hide the overlay") {}
            xit("should not be undoable") {}
        }
        describe("submitting") {
            xit("should respond if there is text (no image)") {}
            xit("should respond if there is an image (no text)") {}
            xit("should respond if there is text and image") {}
            xit("should NOT respond if there is NO text OR image") {}
        }
        describe("pressing remove image") {
            xit("should clear the image") {}
        }
        describe("pressing add image") {
            xit("should open an image selector") {}
        }
        describe("reporting an error") {
            xit("should accept an error") {}
        }
        describe("determining undo state") {
            describe("if there is text or image") {
                xit("should be false (text only)") {}
                xit("should be false (image only)") {}
                xit("should be false (text and image)") {}
                xit("should be true (no text/image, and undo text is set)") {}
                xit("should be true (no text/image, and undo image is set)") {}
                xit("should be true (no text/image, and undo text and image is set)") {}
                xit("should be false (no text, no image, no undo text, no undo image)") {}
            }
        }
    }
}