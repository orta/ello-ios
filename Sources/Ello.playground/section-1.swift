// Playground - noun: a place where people can play

import Foundation
import UIKit

func isGreater(a:Int, b:Int) -> Bool {
    return a > b
}

isGreater(8,6)


var ages = [6,2,9,1,10]

sort(&ages) { (a:Int, b:Int) in
    return a > b
}
