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

//wordAtIndex("ss.ss")

findUsername("blah")
findUsername("@blah")



extension String {

    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

func parse(str: String, location: Int) -> (Range<String.Index>, String) {

    let wordStartIndex = getIndexOfWordStart(location, fromString: str)
    let wordEndIndex = getIndexOfWordEnd(location, fromString: str)
    let range = wordStartIndex...wordEndIndex
    return (range, str.substringWithRange(range))
//    return wordStartIndex...wordEndIndex
//    println(wordStartIndex)
//    println(wordEndIndex)
}

func getIndexOfWordEnd(index: Int, fromString str: String) -> String.Index {
    var cursorIndex = advance(str.startIndex, index)
    var endIndex = str.endIndex.predecessor()
    for index in cursorIndex..<str.endIndex {
        var found = false
        switch str[index] {
        case ".", " ":
            endIndex = index.predecessor()
            found = true
        default: break
        }
        if found { break }
    }
    return endIndex
}


func getIndexOfWordStart(index: Int, fromString str: String) -> String.Index {
    var startIndex = 0
    for var i = index ; i > 0 ; i-- {
        var cursorIndex = advance(str.startIndex, i)
        switch str[cursorIndex] {
        case "@", " ":
            if i != index { startIndex = i + 1 }
        default: break
        }
        if startIndex != 0 { break }
    }
    return advance(str.startIndex, startIndex)
}

//getIndexOfWordStart(4, fromString: "Jack Dougherty")
//getIndexOfWordEnd(4, fromString: "Jack Dougherty")

parse("Jack Dougherty", 6)
