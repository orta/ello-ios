//
//  FreeMethods.swift
//  Ello
//
//  Created by Colin Gray on 5/8/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AnimationOptions {
    let duration: NSTimeInterval
}

public func animate(duration: NSTimeInterval = 0.2, animated: Bool = true, animations: ()->()) {
    let options = AnimationOptions(duration: duration)
    animate(options, animated: animated, animations)
}

public func animate(options: AnimationOptions, animated: Bool = true, animations: ()->()) {
    let duration = options.duration
    if animated {
        UIView.animateWithDuration(duration, animations: animations)
    }
    else {
        animations()
    }
}



public typealias BasicBlock = (()->())
public typealias ThrottledBlock = ((BasicBlock)->())
public typealias CancellableBlock = Bool -> ()
public typealias TakesIndexBlock = ((Int)->())


public class Proc {
    var block: BasicBlock

    public init(_ block: BasicBlock) {
        self.block = block
    }

    @objc
    func run() {
        block()
    }
}


public func times(times: Int, @noescape block: BasicBlock) {
    times_(times) { (index: Int) in block() }
}

public func times(times: Int, @noescape block: TakesIndexBlock) {
    times_(times, block)
}

private func times_(times: Int, @noescape block: TakesIndexBlock) {
    if times <= 0 {
        return
    }
    for var i = 0 ; i < times ; ++i {
        block(i)
    }
}

public func after(times: Int, block: BasicBlock) -> BasicBlock {
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

public func until(times: Int, block: BasicBlock) -> BasicBlock {
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

public func once(block: BasicBlock) -> BasicBlock {
    return until(1, block)
}

public func timeout(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    let handler = once(block)
    _ = delay(duration) {
        handler()
    }
    return handler
}

public func delay(duration: NSTimeInterval, block: BasicBlock) {
    let proc = Proc(block)
    let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
}

public func cancelableDelay(duration: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    let proc = Proc(block)
    let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: proc, selector: "run", userInfo: nil, repeats: false)
    return {
        timer.invalidate()
    }
}

public func debounce(timeout: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    var timer: NSTimer? = nil
    let proc = Proc(block)

    return {
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: "run", userInfo: nil, repeats: false)
    }
}

public func debounce(timeout: NSTimeInterval) -> ThrottledBlock {
    var timer: NSTimer? = nil

    return { block in
        if let prevTimer = timer {
            prevTimer.invalidate()
        }
        let proc = Proc(block)
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: "run", userInfo: nil, repeats: false)
    }
}

public func throttle(interval: NSTimeInterval, block: BasicBlock) -> BasicBlock {
    var timer: NSTimer? = nil
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

public func throttle(interval: NSTimeInterval) -> ThrottledBlock {
    var timer: NSTimer? = nil
    var lastBlock: BasicBlock?

    return { block in
        lastBlock = block

        if timer == nil {
            let proc = Proc() {
                timer = nil
                lastBlock?()
            }

            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: proc, selector: "run", userInfo: nil, repeats: false)
        }
    }
}
