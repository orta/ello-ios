//
//  ElloEquallySpacedLayout.swift
//  Ello
//
//  Created by Colin Gray on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class ElloEquallySpacedLayoutSpec: QuickSpec {
    override func spec() {
        var subject = ElloEquallySpacedLayout()
        var view1 = UIView()
        var view2 = UIButton()
        var view3 = UILabel()
        var views : [UIView] = []
        var rect = CGRect(x:0,y:0,width:0,height:0)

        describe("Is not broken") {
            it("can be created") {
                expect(ElloEquallySpacedLayout()).notTo(beNil())
            }
            it("is a UIView") {
                expect(ElloEquallySpacedLayout()).to(beAKindOf(UIView))
            }
        }
        describe("Can contain views") {

            beforeEach() {
                subject = ElloEquallySpacedLayout(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
                view1 = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                view2 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                view3 = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                views = [view1, view2, view3]
                for view in views {
                    subject.addSubview(view)
                }
                subject.layoutIfNeeded()
            }
            describe("-layoutSubviews") {
                describe("should layout view1") {
                    beforeEach() {
                        rect = CGRect(x: 0, y: 0, width: 30, height: 30)
                    }
                    it("should set x")      { expect(view1.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view1.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view1.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view1.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view2") {
                    beforeEach() {
                        rect = CGRect(x: 30, y: 0, width: 30, height: 30)
                    }
                    it("should set x")      { expect(view2.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view2.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view2.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view2.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view3") {
                    beforeEach() {
                        rect = CGRect(x: 60, y: 0, width: 30, height: 30)
                    }
                    it("should set x")      { expect(view3.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view3.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view3.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view3.frame.size.height).to(equal(rect.size.height)) }
                }
            }

            describe("-layoutSubviews with spacing") {
                beforeEach() {
                    subject.spacing = 15
                }
                describe("should layout view1") {
                    beforeEach() {
                        rect = CGRect(x: 0, y: 0, width: 20, height: 30)
                    }
                    it("should set x")      { expect(view1.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view1.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view1.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view1.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view2") {
                    beforeEach() {
                        rect = CGRect(x: 35, y: 0, width: 20, height: 30)
                    }
                    it("should set x")      { expect(view2.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view2.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view2.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view2.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view3") {
                    beforeEach() {
                        rect = CGRect(x: 70, y: 0, width: 20, height: 30)
                    }
                    it("should set x")      { expect(view3.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view3.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view3.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view3.frame.size.height).to(equal(rect.size.height)) }
                }
            }

            describe("-layoutSubviews with margins") {
                beforeEach() {
                    subject.margins = UIEdgeInsets(top: 6, left: 20, bottom: 4, right: 10)
                }
                describe("should layout view1") {
                    beforeEach() {
                        rect = CGRect(x: 20, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view1.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view1.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view1.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view1.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view2") {
                    beforeEach() {
                        rect = CGRect(x: 40, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view2.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view2.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view2.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view2.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view3") {
                    beforeEach() {
                        rect = CGRect(x: 60, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view3.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view3.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view3.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view3.frame.size.height).to(equal(rect.size.height)) }
                }
            }

            describe("-layoutSubviews with margins and spacing") {
                beforeEach() {
                    subject.margins = UIEdgeInsets(top: 6, left: 15, bottom: 4, right: 5)
                    subject.spacing = 5
                }
                describe("should layout view1") {
                    beforeEach() {
                        rect = CGRect(x: 15, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view1.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view1.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view1.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view1.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view2") {
                    beforeEach() {
                        rect = CGRect(x: 40, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view2.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view2.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view2.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view2.frame.size.height).to(equal(rect.size.height)) }
                }
                describe("should layout view3") {
                    beforeEach() {
                        rect = CGRect(x: 60, y: 6, width: 20, height: 20)
                    }
                    it("should set x")      { expect(view3.frame.origin.x).to(equal(rect.origin.x)) }
                    it("should set y")      { expect(view3.frame.origin.y).to(equal(rect.origin.y)) }
                    it("should set width")  { expect(view3.frame.size.width).to(equal(rect.size.width)) }
                    it("should set height") { expect(view3.frame.size.height).to(equal(rect.size.height)) }
                }
            }
        }
    }
}
