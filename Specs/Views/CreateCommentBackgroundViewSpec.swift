//
//  CreateCommentBackgroundViewSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/10/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class CreateCommentBackgroundViewSpec: QuickSpec {
    override func spec() {
        describe("basic view stuff") {
            it("is a view") {
                expect(CreateCommentBackgroundView()).to(beAKindOf(UIView))
                expect(CreateCommentBackgroundView(frame: CGRectZero)).to(beAKindOf(UIView))
            }
        }
    }
}
