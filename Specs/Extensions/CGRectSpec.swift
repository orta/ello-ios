//
//  CGRectSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//


import Quick
import Nimble

class CGRectExtensionSpec: QuickSpec {
    override func spec() {
        let frame = CGRect(x: 1, y: 2, width: 3, height: 4)
        describe("-x:") {
            let newFrame = frame.x(5)
            it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
            it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
            it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
            it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
        }
        describe("-y:") {
            let newFrame = frame.y(5)
            it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
            it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
            it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
            it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
        }
        describe("-width:") {
            let newFrame = frame.width(5)
            it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
            it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
            it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(5)))}
            it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
        }
        describe("-height:") {
            let newFrame = frame.height(5)
            it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
            it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
            it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
            it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(5)))}
        }
    }
}
