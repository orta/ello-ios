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

        describe("-copyWithCorrectOrientationAndSize") {

            context("no scaling") {
                beforeEach {
                    image = UIImage(named: "specs-avatar")
                    oriented = image.copyWithCorrectOrientationAndSize()
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

            context("scaling") {
                beforeEach {
                    image = UIImage(named: "specs-xcode")
                    oriented = image.copyWithCorrectOrientationAndSize()
                }

                it("scales to the maxWidth") {
                    expect(image.size.width).to(equal(2672.0))
                    expect(image.size.height).to(equal(1525.0))
                    expect(oriented.size.width).to(equal(1200.0))
                    expect(oriented.size.height).to(equal(685.0))
                }
            }
        }
    }
}
