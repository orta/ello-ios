//
//  AsyncOperation.swift
//  Ello
//
//  Created by Colin Gray on 9/16/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class AsyncOperation: NSOperation {
    typealias Block = (() -> Void) -> Void
    let block: Block
    private var _executing: Bool = false
    override var executing: Bool {
        return _executing
    }
    private var _finished: Bool = false
    override var finished: Bool {
        return _finished
    }
    override var asynchronous: Bool { return true }

    init(block: Block) {
        self.block = block
        super.init()
    }

    override func start() {
        willChangeValueForKey("isExecuting")
        _executing = true
        didChangeValueForKey("isExecuting")

        let done = {
            self.willChangeValueForKey("isExecuting")
            self._executing = false
            self.didChangeValueForKey("isExecuting")

            self.willChangeValueForKey("isFinished")
            self._finished = true
            self.didChangeValueForKey("isFinished")
        }

        block(done)
    }
}
