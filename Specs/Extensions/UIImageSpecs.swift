//
//  UIImageSpecs.swift
//  Ello
//
//  Created by Colin Gray on 3/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class UIImageSpecs: QuickSpec {
    override func spec() {
        var image: UIImage!
        var oriented: UIImage!

        describe("isGif") {
            let isGif = NSData(base64EncodedString: "R0lGODdhCg==", options: NSDataBase64DecodingOptions())!
            let notGif = NSData(base64EncodedString: "dGVzdA==", options: NSDataBase64DecodingOptions())!
            it("is a gif") {
                expect(UIImage(isGif)) == true
            }
            it("is not a gif") {
                expect(UIImage(notGif)) == false
            }
        }

        describe("copyWithCorrectOrientationAndSize") {

            context("no scaling") {
                beforeEach {
                    image = UIImage(named: "specs-avatar", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
                    image.copyWithCorrectOrientationAndSize() { image in
                        oriented = image
                    }
                }

                it("returns an image") {
                    expect(oriented).to(beAKindOf(UIImage.self))
                }

                it("with the correct size") {
                    expect(oriented.size).to(equal(image.size))
                }

                it("with the correct scale") {
                    expect(oriented.scale).to(equal(image.scale))
                }
            }

            context("scaling when width is greater than max") {
                beforeEach {
                    image = UIImage(named: "specs-4000x1000", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
                    image.copyWithCorrectOrientationAndSize() { image in
                        oriented = image
                    }
                }

                it("scales to the maxWidth") {
                    expect(image.size.width).to(equal(4000.0))
                    expect(image.size.height).to(equal(1000.0))
                    expect(oriented.size.width).to(equal(1200.0))
                    expect(oriented.size.height).to(equal(300.0))
                }
            }

            context("scaling when height is greater than max") {
                beforeEach {
                    image = UIImage(named: "specs-1000x4000", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
                    image.copyWithCorrectOrientationAndSize() { image in
                        oriented = image
                    }
                }

                it("scales to the maxWidth") {
                    expect(image.size.width).to(equal(1000.0))
                    expect(image.size.height).to(equal(4000.0))
                    expect(oriented.size.width).to(equal(900.0))
                    expect(oriented.size.height).to(equal(3600.0))
                }
            }
        }
    }
}
