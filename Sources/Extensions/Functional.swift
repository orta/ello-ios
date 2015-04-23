//
//  Functional.swift
//
//  Based on the Function helpers on underscorejs.org
//

import Foundation

public struct Functional {
    public typealias BasicBlock = (()->())
    public typealias CancellableBlock = Bool -> ()
    public typealias TakesIndexBlock = ((Int)->())

    public class Proc {
        var block : BasicBlock

        public init(block : BasicBlock) {
            self.block = block
        }

        @objc
        func run() {
            block()
        }
    }

    // Simple wrapper for `for i = 0 ; i < times ; ++i`.  Ignores the index.
    public static func times(times: Int, block : BasicBlock) {
        self.times(times, block: { (index : Int) in block() })
    }

    // Simple wrapper for `for i = 0 ; i < times ; ++i`.  Passes the index to
    // the block.
    public static func times(times: Int, block : TakesIndexBlock) {
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
    public static func after(times : Int, block : BasicBlock) -> BasicBlock {
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
    public static func until(times : Int, block : BasicBlock) -> BasicBlock {
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
    public static func once(block : BasicBlock) -> BasicBlock {
        return until(1, block: block)
    }

    // This block can be called multiple times, but it's guaranteed to be called
    // after the timeout duration
    public static func timeout(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
        let handler = once(block)
        _ = delay(duration) {
            handler()
        }
        return handler
    }

    public static func delay(duration: NSTimeInterval, block: BasicBlock) {
        let proc = Proc(block: block)
        let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
    }

    public static func cancelableDelay(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
        let proc = Proc(block: block)
        let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
        return {
            timer.invalidate()
        }
    }

    // Calling this method multiple times resets the internal timer.  After
    // the timeout has been reached, the block is called.  Useful for things
    // like updating the UI after the user has "stopped typing" (ie hasn't hit a
    // key for 1/2 a sec or so)
    public static func debounce(timeout: NSTimeInterval, block: BasicBlock) -> BasicBlock {
        var timer : NSTimer? = nil
        let proc = Proc(block: block)

        return {
            if let prevTimer = timer {
                prevTimer.invalidate()
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: "run", userInfo: nil, repeats: false)
        }
    }

    // The difference with `debounce`, is that this method is guaranteed to run
    // every `interval` seconds.  If `debounce` is useful for keyboard / UI,
    // this method is useful for slowing down events, like a chat client that
    // needs to insert chat messages and not be herky jerky.
    public static func throttle(interval: NSTimeInterval, block: BasicBlock) -> BasicBlock {
        var timer : NSTimer? = nil
        let proc = Proc() {
            timer = nil
            block()
        }

        return {
            if timer == nil {
                timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: proc, selector: "run", userInfo: nil, repeats: false)
            }
        }
    }

}
