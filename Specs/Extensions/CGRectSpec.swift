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
        describe("getters") {
            let badFrame = CGRect(x: 4, y: 2, width: -4, height: -2)
            it("should return raw values") {
                expect(badFrame.x).to(equal(CGFloat(4)))
                expect(badFrame.y).to(equal(CGFloat(2)))
                expect(badFrame.width).to(equal(CGFloat(-4)))
                expect(badFrame.height).to(equal(CGFloat(-2)))
            }
            it("should return normalized values") {
                expect(badFrame.minX).to(equal(CGFloat(0)))
                expect(badFrame.midX).to(equal(CGFloat(2)))
                expect(badFrame.maxX).to(equal(CGFloat(4)))
                expect(badFrame.minY).to(equal(CGFloat(0)))
                expect(badFrame.midY).to(equal(CGFloat(1)))
                expect(badFrame.maxY).to(equal(CGFloat(2)))
                expect(badFrame.absWidth).to(equal(CGFloat(4)))
                expect(badFrame.absHeight).to(equal(CGFloat(2)))
            }
        }
        describe("setters") {
            let frame = CGRect(x: 1, y: 2, width: 3, height: 4)
            it("-atOrigin:") {
                let newFrame = frame.atOrigin(CGPoint(5, 5))
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            it("-withSize:") {
                let newFrame = frame.withSize(CGSize(5, 5))
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(5)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(5)))}
            }
            it("-atX:") {
                let newFrame = frame.atX(5)
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            it("-atY:") {
                let newFrame = frame.atY(5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            it("-withWidth:") {
                let newFrame = frame.withWidth(5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(5)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            it("-withHeight:") {
                let newFrame = frame.withHeight(5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(5)))}
            }
        }
        describe("inset(Xyz:)") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-inset(all:)") {
                let newFrame = frame.inset(all: 1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 8, width: 8, height: 12)))
            }
            it("-inset(topBottom:sides:)") {
                let newFrame = frame.inset(topBottom: 1, sides: 2)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 6, height: 12)))
            }
            it("-inset(top:sides:bottom:)") {
                let newFrame = frame.inset(top: 1, sides: 2, bottom: 3)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 6, height: 10)))
            }
            it("-inset(top:left:bottom:right:)") {
                let newFrame = frame.inset(top: 1, left: 2, bottom: 3, right: 4)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 4, height: 10)))
            }
        }
    }
}
