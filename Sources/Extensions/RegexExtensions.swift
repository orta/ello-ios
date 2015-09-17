//
//  RegexExtensions.swift
//  Ello
//
//  Created by Colin Gray on 9/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class Regex {
    let regex: NSRegularExpression!
    let pattern: String

    init?(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue: 0))
        } catch let error1 as NSError {
            error = error1
            self.regex = nil
        }
        if error != nil { return nil }
    }

    func test(input: String) -> Bool {
        return match(input) != nil
    }

    func match(input: String) -> String? {
        if let range = input.rangeOfString(pattern, options: .RegularExpressionSearch) {
            return input.substringWithRange(range)
        }
        return nil
    }

    func matches(input: String) -> [String] {
        let nsstring = input as NSString
        let matches = self.regex.matchesInString(input, options: [], range: NSRange(location: 0, length: nsstring.length))
        var ret = [String]()
        for match in matches {
            for i in 0..<match.numberOfRanges {
                let range = match.rangeAtIndex(i)
                ret.append(nsstring.substringWithRange(range))
            }
            break
        }
        return ret
    }

}

infix operator =~ {}
infix operator !~ {}
infix operator ~ {}
func =~ (input: String, pattern: String) -> Bool {
    if let regex = Regex(pattern) {
        return regex.test(input)
    }
    return false
}
func !~ (input: String, pattern: String) -> Bool {
    if let regex = Regex(pattern) {
        return !regex.test(input)
    }
    return false
}
func ~ (input: String, pattern: String) -> String? {
    if let regex = Regex(pattern) {
        return regex.match(input)
    }
    return nil
}
