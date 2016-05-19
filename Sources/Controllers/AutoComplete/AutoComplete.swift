//
//  AutoComplete.swift
//  Ello
//
//  Created by Sean on 7/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AutoCompleteMatch: CustomStringConvertible, Equatable {

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

public func == (lhs: AutoCompleteMatch, rhs: AutoCompleteMatch) -> Bool {
    return lhs.type == rhs.type && lhs.range == rhs.range && lhs.text == rhs.text
}

public enum AutoCompleteType: String, CustomStringConvertible {
    case Emoji = "Emoji"
    case Username = "Username"

    public var description: String {
        return self.rawValue
    }
}

public struct AutoComplete {

    public init(){}

    public func check(text: String, location: Int) -> AutoCompleteMatch? {

        if location >= text.characters.count { return .None }

        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
        let wordEndIndex = text.startIndex.advancedBy(location)
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

        if let type = type, range = range, word = word
        where matchFound {
            return AutoCompleteMatch(type: type, range: range, text: word)
        }
        else {
            return .None
        }
    }
}

private let usernameRegex = Regex("([^\\w]|\\s|^)@(\\w+)")!
private let emojiRegex = Regex("([^\\w]|\\s|^):(\\w+)")!

private extension AutoComplete {

    func findUsername(text: String) -> Bool {
        return text =~ usernameRegex
    }

    func findEmoji(text: String) -> Bool {
        // this handles ':one:two'
        if (text.characters.split { $0 == ":" }.map { String($0) }).count > 1 {
            return false
        }
        return text =~ emojiRegex
    }

    func getIndexOfWordStart(index: Int, fromString str: String) -> String.Index {
        guard index > 0 else { return str.startIndex }
        var indexOffset = 0
        for i in (1 ... index).reverse() {
            let cursorIndex = str.startIndex.advancedBy(i)
            let letter = str[cursorIndex]
            var prevLetter: Character?
            if i > 0 {
                prevLetter = str[cursorIndex.predecessor()]
            }
            switch letter {
            case " ", "\n", "\r", "\t":
                if i != index { indexOffset = i + 1 }
                else {
                    indexOffset = i - 1
                }
            case ":":
                if let _ = prevLetter {
                    if prevLetter == " " || prevLetter == ":" || prevLetter == nil {
                        if i != index { indexOffset = i }
                    }
                    else {
                        break
                    }
                }
            default: break
            }
            if indexOffset != 0 { break }
        }
        return str.startIndex.advancedBy(indexOffset)
    }
}
