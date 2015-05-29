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

        // this is sad, async tests suck, we have to turn these off. I'd like to move to promises or futures that have a hook for synchronous test execution eventuallyy
        xdescribe("-copyWithCorrectOrientationAndSize") {

            context("no scaling") {
                beforeEach {
                    image = UIImage(named: "specs-avatar", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
                    image.copyWithCorrectOrientationAndSize() { image in
                        oriented = image
                    }
                }

                it("returns an image") {
                    expect(oriented).toEventually(beAKindOf(UIImage.self))
                }

                it("with the correct size") {
                    expect(oriented.size).toEventually(equal(image.size))
                }

                it("with the correct scale") {
                    expect(oriented.scale).toEventually(equal(image.scale))
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
                    expect(image.size.width).toEventually(equal(4000.0))
                    expect(image.size.height).toEventually(equal(1000.0))
                    expect(oriented.size.width).toEventually(equal(1200.0))
                    expect(oriented.size.height).toEventually(equal(300.0))
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
                    expect(image.size.width).toEventually(equal(1000.0))
                    expect(image.size.height).toEventually(equal(4000.0))
                    expect(oriented.size.width).toEventually(equal(900.0))
                    expect(oriented.size.height).toEventually(equal(3600.0))
                }
            }
        }
    }
}
