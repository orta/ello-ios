//
//  AutoComplete.swift
//  Ello
//
//  Created by Sean on 7/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AutoCompleteMatch: Printable, Equatable {

    public var description: String {
        return "type: \(self.type), range: \(self.range), text: \(self.text)"
    }

    public let type: AutoCompleteType
    public let range: Range<String.Index>
    public let text: String

    public init(type: AutoCompleteType, range: Range<String.Index>, text: String ){
        self.type = type
        self.range = range
        self.text = text
    }
}

public func ==(lhs: AutoCompleteMatch, rhs: AutoCompleteMatch) -> Bool {
    return lhs.type == rhs.type && lhs.range == rhs.range && lhs.text == rhs.text
}

public enum AutoCompleteType: String, Printable {
    case Emoji = "Emoji"
    case Username = "Username"

    public var description: String {
        return self.rawValue
    }
}

public struct AutoComplete {

    public init(){}
    
    public func check(text:String, location: Int) -> AutoCompleteMatch? {

        if location >= count(text) { return .None }

        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
//        let wordEndIndex = getIndexOfWordEnd(location, fromString: text)
        var wordEndIndex = advance(text.startIndex, location)
        if wordStartIndex >= wordEndIndex { return .None }

        var range: Range<String.Index>?
        var word: String?
        var type: AutoCompleteType?
        var matchFound = false

        range = wordStartIndex...wordEndIndex
        if let range = range {
            word = text.substringWithRange(range)
            if let word = word {
                if findUsername(word) {
                    type = .Username
                    matchFound = true
                }
                else if findEmoji(word) {
                    type = .Emoji
                    matchFound = true
                }
            }
        }

        if matchFound && range != nil && word != nil && type != nil {
            return AutoCompleteMatch(type: type!, range: range!, text: word!)
        }
        else {
            return .None
        }
    }
}

private extension AutoComplete {

    func findUsername(text: String) -> Bool {
        return text.rangeOfString("\\s?@{1}\\w+", options: .RegularExpressionSearch) != nil
    }

    func findEmoji(text: String) -> Bool {
        return text.rangeOfString("\\s?:{1}\\w+", options: .RegularExpressionSearch) != nil
    }

//    func getIndexOfWordEnd(index: Int, fromString str: String) -> String.Index {
//        if count(str) == 0 { return str.startIndex }
//        var cursorIndex = advance(str.startIndex, index)
//        var endIndex = str.endIndex.predecessor()
//        for index in cursorIndex..<str.endIndex {
//            var found = false
//            switch str[index] {
//            case ".", " ", "?", "!", ",", "'":
//                endIndex = index.predecessor()
//                found = true
//            default: break
//            }
//            if found { break }
//        }
//        return endIndex
//    }


    func getIndexOfWordStart(index: Int, fromString str: String) -> String.Index {
        var startIndex = 0
        for var i = index ; i > 0 ; i-- {
            var cursorIndex = advance(str.startIndex, i)
            switch str[cursorIndex] {
            case " ", ":":
                if i != index { startIndex = i}
            default: break
            }
            if startIndex != 0 { break }
        }
        return advance(str.startIndex, startIndex)
    }
}
