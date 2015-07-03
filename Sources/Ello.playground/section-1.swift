// Playground - noun: a place where people can play

import Foundation
import UIKit


func findUsername(text: String) -> (Bool, String?) {
    if text.rangeOfString("\\s?@{1}\\w+", options: .RegularExpressionSearch) != nil {
        return (true, text)
    }
    else {
        return (false, nil)
    }
}

func wordAtIndex(text: String, range: Range<String.Index>) -> String? {
    var range = text.rangeOfString(".", options: .BackwardsSearch)?.startIndex
    println(range)
    return nil
}

wordAtIndex("ss.ss")

findUsername("blah")
findUsername("@blah")
