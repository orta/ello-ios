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
public typealias TakesBasicBlock = ((BasicBlock)->())
public typealias ThrottledBlock = TakesBasicBlock
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
