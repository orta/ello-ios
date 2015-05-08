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
