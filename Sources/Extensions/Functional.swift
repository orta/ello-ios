//
//  Functional.swift
//

import Foundation

struct Functional {
    typealias BasicBlock = (()->())

    class Proc {
        var block : BasicBlock

        init(block : BasicBlock) {
            self.block = block
        }

        @objc
        func run() {
            block()
        }
    }

    static func times(times: Int, block : BasicBlock) {
        if times <= 0 {
            return
        }
        for var i = 0 ; i < times ; ++i {
            block()
        }
    }

    // this is used when you have multiple callbacks, and you need an "all done" block
    // called when *all* the callbacks have been executed.  Similar in concept to GCD
    // groups.
    static func after(times : Int, block : BasicBlock) -> BasicBlock {
        if times == 0 {
            block()
            return {}
        }

        var remaining = times
        return {
            remaining -= 1
            if remaining == 0 {
                block()
            }
        }
    }

    //
    static func until(times : Int, block : BasicBlock) -> BasicBlock {
        if times == 0 {
            return {}
        }

        var remaining = times
        return {
            remaining -= 1
            if remaining >= 0 {
                block()
            }
        }
    }

    static func once(block : BasicBlock) -> BasicBlock {
        return until(1, block)
    }

    static func timeout(time : Double, block : BasicBlock) -> BasicBlock {
        let handler = once { block() }
        let proc = Proc(handler)
        NSTimer.scheduledTimerWithTimeInterval(time, target: proc, selector: "run", userInfo: nil, repeats: false)
        return handler
    }

    static func throttle(timeout : Double, block : BasicBlock) -> BasicBlock {
        var timer : NSTimer? = nil
        let proc = Proc(block)

        return {
            if let prevTimer = timer {
                prevTimer.invalidate()
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: "run", userInfo: nil, repeats: false)
        }
    }

}