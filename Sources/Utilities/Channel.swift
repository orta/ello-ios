//
//  Channel.swift
//  Ello
//
//  Created by Colin Gray on 7/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

func go(block: ()->()) {
    dispatch_async(dispatch_queue_create("go", DISPATCH_QUEUE_CONCURRENT), block)
}

class Channel<T> {
    var values = [T]()
    func append(input: T) {
        values.append(input)
    }

    func output() -> T {
        while values.count == 0 {}
        var retval = values.first!
        values.removeAtIndex(0)
        return retval
    }
}

infix operator <- { precedence 170 }
prefix operator <- {}

func <- <T>(lhs: Channel<T>, rhs: T) -> Channel<T> {
    lhs.append(rhs)
    return lhs
}

prefix func <- <T>(lhs: Channel<T>) -> T {
    return lhs.output()
}
