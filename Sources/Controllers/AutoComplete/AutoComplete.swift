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
        let wordEndIndex = advance(text.startIndex, location)
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
//                uncomment when we add emoji autocomplete endpoints
//                else if findEmoji(word) {
//                    type = .Emoji
//                    matchFound = true
//                }
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
        return text.rangeOfString("([^\\w]|\\s|^)@\\w+", options: .RegularExpressionSearch) != nil
    }

    func findEmoji(text: String) -> Bool {
        // this handles ':one:two'
        if (split(text) { $0 == ":" }).count > 1 {
            return false
        }
        return text.rangeOfString("([^\\w]|\\s|^):\\w+", options: .RegularExpressionSearch) != nil
    }

    func getIndexOfWordStart(index: Int, fromString str: String) -> String.Index {
        var startIndex = 0
        for var i = index ; i > 0 ; i-- {
            var cursorIndex = advance(str.startIndex, i)
            var letter = str[cursorIndex]
            var prevLetter: Character?
            if i > 0 {
                prevLetter = str[cursorIndex.predecessor()]
            }
            switch letter {
            case " ", "\n", "\r", "\t":
                if i != index { startIndex = i + 1 }
                else {
                    startIndex = i - 1
                }
            case ":":
                if let prev = prevLetter {
                    if prevLetter == " " || prevLetter == ":" || prevLetter == nil {
                        if i != index { startIndex = i }
                    }
                    else {
                        break
                    }
                }
            default: break
            }
            if startIndex != 0 { break }
        }
        return advance(str.startIndex, startIndex)
    }
}
