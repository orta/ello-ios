//
//  ExtensionItemPreviewSpec.swift
//  Ello
//
//  Created by Sean on 2/10/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class ExtensionItemPreviewSpec: QuickSpec {
    override func spec() {

        describe("ExtensionItemPreview") {

            describe("==") {
                let imageA = UIImage()
                let imageB = UIImage()
                let urlA = NSURL(string: "https://ello.co")
                let urlB = NSURL(string: "https://ello.co")
                let urlC = NSURL(string: "https://status.ello.co")

                let tests: [(Bool, ExtensionItemPreview, ExtensionItemPreview)] = [
                    (true, ExtensionItemPreview(image: nil, imagePath: nil, text: nil), ExtensionItemPreview(image: nil, imagePath: nil, text: nil)),
                    (true, ExtensionItemPreview(image: imageA, imagePath: nil, text: nil), ExtensionItemPreview(image: imageA, imagePath: nil, text: nil)),
                    (true, ExtensionItemPreview(image: nil, imagePath: urlA, text: nil), ExtensionItemPreview(image: nil, imagePath: urlB, text: nil)),
                    (true, ExtensionItemPreview(image: nil, imagePath: nil, text: "text"), ExtensionItemPreview(image: nil, imagePath: nil, text: "text")),
                    (true, ExtensionItemPreview(image: imageA, imagePath: nil, text: "text"), ExtensionItemPreview(image: imageA, imagePath: nil, text: "text")),
                    (true, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "text")),
                    (false, ExtensionItemPreview(image: nil, imagePath: urlA, text: nil), ExtensionItemPreview(image: nil, imagePath: urlC, text: nil)),
                    (false, ExtensionItemPreview(image: imageA, imagePath: nil, text: "text"), ExtensionItemPreview(image: imageB, imagePath: nil, text: "text")),
                    (false, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "different text"))
                ]

                for (equal, a, b) in tests {

                    it("identifies equality correctly") {
                        expect(a == b) == equal
                    }

                }
            }
        }
    }
}
