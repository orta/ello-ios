//
//  FunctionalSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class FunctionalSpec: QuickSpec {
    override func spec() {
        describe("+after:") {
            it("gets called after(2)") {
                var called = 0
                var after = Functional.after(2) { called += 1 }
                expect(called).to(equal(0))
                after()
                expect(called).to(equal(0))
                after()
                expect(called).to(equal(1))
            }
            it("only gets called once after(2)") {
                var called = 0
                var after = Functional.after(2) { called += 1 }
                expect(called).to(equal(0))
                after()
                expect(called).to(equal(0))
                after()
                expect(called).to(equal(1))
                after()
                expect(called).to(equal(1))
            }
            it("gets called immediately after(0)") {
                var called = 0
                var after = Functional.after(0) { called += 1 }
                expect(called).to(equal(1))
            }
        }
        describe("+until:") {
            it("should get called until(2)") {
                var called = 0
                var until = Functional.until(2) { called += 1 }
                expect(called).to(equal(0))
                until()
                expect(called).to(equal(1))
                until()
                expect(called).to(equal(2))
                until()
                expect(called).to(equal(2))
            }
            it("should never get called until(0)") {
                var called = 0
                var until = Functional.until(0) { called += 1 }
                expect(called).to(equal(0))
                until()
                expect(called).to(equal(0))
            }
        }
        describe("+once") {
            it("should get called once") {
                var called = 0
                var once = Functional.once { called += 1 }
                expect(called).to(equal(0))
                once()
                expect(called).to(equal(1))
                once()
                expect(called).to(equal(1))
            }
        }
        describe("+timeout:") {
            xit("should call the timeout") {
                var called = 0
                var timeout = Functional.timeout(0.1) { called += 1 }
                expect(called).to(equal(0))
                expect(called).toEventually(equal(1), timeout: 0.2)
            }
            xit("should call the timeout immediately") {
                var called = 0
                var timeout = Functional.timeout(0.1) { called += 1 }
                expect(called).to(equal(0))
                timeout()
                expect(called).to(equal(1))
                expect(called).toEventually(equal(1), timeout: 0.11)
            }
        }
        describe("+throttle:") {
            xit("should throttle the block") {
                var called = 0
                var throttle = Functional.throttle(0.1) { called += 1 }
                expect(called).to(equal(0))
                throttle()
                expect(called).to(equal(0))

                // reset the timer
                expect(called).toEventually(equal(0), timeout: 0.1)
                var timeout = Functional.timeout(0.05) { throttle() }

                expect(called).toEventually(equal(1), timeout: 0.2)
            }
        }
    }
}
