//
//  UIViewExtensionsSpec.swift
//  Ello
//
//  Created by Sean on 1/25/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class UIViewSpec: QuickSpec {
    override func spec() {
        describe("UIView") {
            describe("addToView(:_)") {
                it("adds self to parent") {
                    let parent = UIView(frame: CGRectZero)
                    var subject: UIView?

                    subject = UIView(frame: CGRectZero)
                    subject?.addToView(parent)
                    expect(subject?.superview) == parent
                }
            }
        }
    }
}
