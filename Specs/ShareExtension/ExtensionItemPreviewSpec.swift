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
                let dataA = NSData()
                let dataB = NSData(base64EncodedString: "dGVzdA==", options: NSDataBase64DecodingOptions())!
                let dataC = NSData(base64EncodedString: "dGVzdA==", options: NSDataBase64DecodingOptions())!
                let urlA = NSURL(string: "https://ello.co")
                let urlB = NSURL(string: "https://ello.co")
                let urlC = NSURL(string: "https://status.ello.co")

                let tests: [(Bool, ExtensionItemPreview, ExtensionItemPreview)] = [
                    (true, ExtensionItemPreview(), ExtensionItemPreview()),
                    (true, ExtensionItemPreview(image: imageA), ExtensionItemPreview(image: imageA)),
                    (true, ExtensionItemPreview(imagePath: urlA), ExtensionItemPreview(imagePath: urlB)),
                    (true, ExtensionItemPreview(gifData: dataA), ExtensionItemPreview(gifData: dataA)),
                    (true, ExtensionItemPreview(gifData: dataB), ExtensionItemPreview(gifData: dataC)),
                    (true, ExtensionItemPreview(text: "text"), ExtensionItemPreview(text: "text")),
                    (true, ExtensionItemPreview(image: imageA, text: "text"), ExtensionItemPreview(image: imageA, text: "text")),
                    (true, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "text")),
                    (false, ExtensionItemPreview(imagePath: urlA), ExtensionItemPreview(imagePath: urlC)),
                    (false, ExtensionItemPreview(image: imageA, text: "text"), ExtensionItemPreview(image: imageB, text: "text")),
                    (false, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "different text")),
                    (false, ExtensionItemPreview(gifData: dataA), ExtensionItemPreview(gifData: dataB)),
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
