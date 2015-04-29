//
//  CGRectSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class CGRectExtensionSpec: QuickSpec {
    override func spec() {
        describe("getters") {
            let badFrame = CGRect(x: 4, y: 2, width: -4, height: -2)
            it("should return raw values") {
                expect(badFrame.x).to(equal(CGFloat(4)))
                expect(badFrame.y).to(equal(CGFloat(2)))
            }
            it("should return center") {
                let center = badFrame.center
                expect(center.x).to(equal(CGFloat(2)))
                expect(center.y).to(equal(CGFloat(1)))
            }
        }

        describe("factories") {
            describe("CGRect.make") {
                let newFrame = CGRect.make(x: 1, y: 2, right: 4, bottom: 6)
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            describe("CGRect.at") {
                let newFrame = CGRect.at(x: 1, y: 2)
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(0)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(0)))}
            }
        }

        describe("setters") {
            let frame = CGRect(x: 1, y: 2, width: 3, height: 4)
            it("-atOrigin:") {
                let newFrame = frame.atOrigin(CGPoint(x: 5, y: 5))
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            it("-withSize:") {
                let newFrame = frame.withSize(CGSize(width: 5, height: 5))
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
            it("-inset(topBottom:)") {
                let newFrame = frame.inset(topBottom: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 12)))
            }
            it("-inset(sides:)") {
                let newFrame = frame.inset(sides: 2)
                expect(newFrame).to(equal(CGRect(x: 7, y: 7, width: 6, height: 14)))
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
        describe("shrinkXyz") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-shrinkLeft:") {
                let newFrame = frame.shrinkLeft(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 9, height: 14)))
            }
            it("-shrinkRight:") {
                let newFrame = frame.shrinkRight(1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 7, width: 9, height: 14)))
            }
            it("-shrinkDown:") {
                let newFrame = frame.shrinkDown(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 13)))
            }
            it("-shrinkUp:") {
                let newFrame = frame.shrinkUp(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 13)))
            }
        }
        describe("grow(Xyz:)") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-grow(all:)") {
                let newFrame = frame.grow(all: 1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 6, width: 12, height: 16)))
            }
            it("-grow(topBottom:sides:)") {
                let newFrame = frame.grow(topBottom: 1, sides: 2)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 14, height: 16)))
            }
            it("-grow(top:sides:bottom:)") {
                let newFrame = frame.grow(top: 1, sides: 2, bottom: 3)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 14, height: 18)))
            }
            it("-grow(top:left:bottom:right:)") {
                let newFrame = frame.grow(top: 1, left: 2, bottom: 3, right: 4)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 16, height: 18)))
            }
        }
        describe("growXyz") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-growLeft:") {
                let newFrame = frame.growLeft(1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 7, width: 11, height: 14)))
            }
            it("-growRight:") {
                let newFrame = frame.growRight(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 11, height: 14)))
            }
            it("-growUp:") {
                let newFrame = frame.growUp(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 6, width: 10, height: 15)))
            }
            it("-growDown:") {
                let newFrame = frame.growDown(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 15)))
            }
        }
        describe("-fromXyz:") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-fromTop:") {
                let newFrame = frame.fromTop()
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 0)))
            }
            it("-fromBottom:") {
                let newFrame = frame.fromBottom()
                expect(newFrame).to(equal(CGRect(x: 5, y: 21, width: 10, height: 0)))
            }
            it("-fromLeft:") {
                let newFrame = frame.fromLeft()
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 0, height: 14)))
            }
            it("-fromRight:") {
                let newFrame = frame.fromRight()
                expect(newFrame).to(equal(CGRect(x: 15, y: 7, width: 0, height: 14)))
            }
        }
        describe("shiftXyz") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-shiftUp:") {
                let newFrame = frame.shiftUp(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 6, width: 10, height: 14)))
            }
            it("-shiftDown:") {
                let newFrame = frame.shiftDown(1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 14)))
            }
            it("-shiftLeft:") {
                let newFrame = frame.shiftLeft(1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 7, width: 10, height: 14)))
            }
            it("-shiftRight:") {
                let newFrame = frame.shiftRight(1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 7, width: 10, height: 14)))
            }
        }
    }
}
