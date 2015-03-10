//
//  Functional.swift
//

import Foundation

struct Functional {
    typealias BasicBlock = (()->())
    typealias TakesIndexBlock = ((Int)->())

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

    // Simple wrapper for `for i = 0 ; i < times ; ++i`.  Ignores the index.
    static func times(times: Int, block : BasicBlock) {
        self.times(times, block: { (index : Int) in block() })
    }

    // Simple wrapper for `for i = 0 ; i < times ; ++i`.  Passes the index to
    // the block.
    static func times(times: Int, block : TakesIndexBlock) {
        if times <= 0 {
            return
        }
        for var i = 0 ; i < times ; ++i {
            block(i)
        }
    }

    // This is used when you have multiple callbacks, and you need an "all done" block
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

    // The block will be called many times - the simplest case is `until(1)` aka
    // `once`, which is only called one time.  After that, calling the block has
    // no effect.
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

    // Using `until(1)`, this is a simple way to make sure a block is only called one time
    static func once(block : BasicBlock) -> BasicBlock {
        return until(1, block)
    }

    // This block can be called multiple times, but it's guaranteed to be called
    // after the timeout duration
    static func timeout(duration : Double, block : BasicBlock) -> BasicBlock {
        let handler = once(block)
        later(duration, handler)
        return handler
    }

    // Calls the block after the specified duration.
    static func later(duration : Double, block : BasicBlock) {
        let proc = Proc(block)
        NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
    }

    // calling this method multiple times resets the internal timer.  After
    // the timeout duration has been reached, the block is called.  This cycle
    // can then start over; if you only want the block to be called once, you
    // should wrap the block with Functional.once()
    static func throttle(duration : Double, block : BasicBlock) -> BasicBlock {
        var timer : NSTimer? = nil
        let proc = Proc(block)

        return {
            if let prevTimer = timer {
                prevTimer.invalidate()
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
        }
    }

}