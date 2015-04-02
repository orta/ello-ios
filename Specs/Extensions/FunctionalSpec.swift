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
        describe("+times:") {
            it("calls the block 5 times") {
                var counter = 0
                Functional.times(5) {
                    counter += 1
                }
                expect(counter).to(equal(5))
            }
            it("calls the block 5 times, passing in the index") {
                var counter = 0
                Functional.times(5) { index in
                    counter += index
                }
                expect(counter).to(equal(10))
            }
        }
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
        // TODO: figure out why this fails on Travis
        describe("+timeout:") {
            it("should call the timeout after a delay") {
                var called = 0
                var timeout = Functional.timeout(0.5) { called += 1 }
                expect(called).to(equal(0))
                expect(called).toEventually(equal(1), timeout: 0.3, pollInterval: 0.1)
            }
            it("should call the timeout immediately, and only call the timeout once") {
                var called = 0
                var timeout = Functional.timeout(0.1) { called += 1 }
                expect(called).to(equal(0))
                timeout()
                expect(called).to(equal(1))
                timeout()
                expect(called).to(equal(1))
                expect(called).toEventually(equal(1), timeout: 0.11, pollInterval: 0.11)
            }
        }
        describe("+debounce:") {
            it("should debounce the block") {
                var called = 0
                var debounced = Functional.debounce(0.1) {
                    println("called: \(called)")
                    called += 1 }
                expect(called).to(equal(0))

                debounced()
                expect(called).to(equal(0))

                // reset the timer
                Functional.delay(0.05) { debounced() }
                expect(called).toEventually(equal(0), timeout: 0.1, pollInterval: 0.1)
                expect(called).toEventually(equal(1), timeout: 0.3, pollInterval: 0.2)
            }
        }
        describe("+throttle:") {
            it("should throttle the block") {
                var called = 0
                var throttled = Functional.throttle(0.1) {
                    called += 1
                    println("called: \(called)")
                }
                expect(called).to(equal(0))
                throttled()
                expect(called).to(equal(0))

                // 0.1 seconds after each delay, throttled should get called
                Functional.delay(0.05) { throttled() }
                expect(called).toEventually(equal(1), timeout: 1, pollInterval: 0.1)
                Functional.delay(0.25) { throttled() }
                expect(called).toEventually(equal(2), timeout: 1, pollInterval: 0.15)
            }
        }
        describe("+delay:") {
            it("should call the block after a delay") {
                var called = 0
                Functional.delay(0.1) { called += 1 }
                expect(called).to(equal(0))
                expect(called).toEventually(equal(1), timeout: 0.2)
            }
        }
        describe("+cancelableDelay:") {
            it("should call the block after a delay") {
                var called = 0
                let cancel = Functional.cancelableDelay(0.1) { called += 1 }
                expect(called).to(equal(0))
                expect(called).toEventually(equal(1), timeout: 0.2)
            }
            it("should cancel the block if called") {
                var called = 0
                let cancel = Functional.cancelableDelay(0.1) { called += 1 }
                expect(called).to(equal(0))
                cancel()
                expect(called).toEventually(equal(0), timeout: 0.3, pollInterval: 0.2)
            }
        }
    }
}
