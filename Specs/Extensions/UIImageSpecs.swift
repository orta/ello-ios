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
        let image = UIImage(named: "specs-avatar")!
        var oriented: UIImage!

        describe("-copyWithCorrectOrientation") {
            beforeEach {
                oriented = image.copyWithCorrectOrientation()
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
    }
}
