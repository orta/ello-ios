//
//  Funky.swift
//

import Foundation

class Proc {
  var block : (()->())

  init(block : (()->())) {
    self.block = block
  }

  @objc
  func run() {
    block()
  }
}

struct Funky {
    static func after(times : Int, block : ()->()) -> (()->()) {
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

    static func until(times : Int, block : ()->()) -> (()->()) {
      var remaining = times
      return {
        remaining -= 1
        if remaining >= 0 {
          block()
        }
      }
    }

    static func once(block : ()->()) -> (()->()) {
      return until(1, block)
    }

    static func timeout(time : Double, block : (()->())) -> (()->()) {
      let handler = once { block() }
      let proc = Proc(handler)
      NSTimer.scheduledTimerWithTimeInterval(time, target: proc, selector: "run", userInfo: nil, repeats: false)
      return handler
    }

    static func throttle(timeout : Double, token : NSTimer?, block : (()->())) -> NSTimer {
      if let token = token {
        token.invalidate()
      }
      let proc = Proc(block)
      return NSTimer.scheduledTimerWithTimeInterval(timeout, target: proc, selector: "run", userInfo: nil, repeats: false)
    }
}