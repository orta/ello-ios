//
//  ElloAttributedString.swift
//  Ello
//
//  Created by Colin Gray on 2/27/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct ElloAttributedString {
    public static func attrs(_ addlAttrs: [String: AnyObject] = [:]) -> [NSObject: AnyObject] {
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.typewriterFont(12),
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        return attrs + addlAttrs
    }

    public static func linkAttrs() -> [NSObject: AnyObject] {
        return attrs([
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
    }

    public static func split(text: NSAttributedString, split: String = "\n") -> [NSAttributedString] {
        var strings = [NSAttributedString]()
        var current = NSMutableAttributedString()
        var hasLetters = false
        var startNewString = false
        let nsCount = (text.string as NSString).length
        for i in 0..<nsCount {
            let letter = NSMutableAttributedString(attributedString: text)
            if i < nsCount - 1 {
                letter.deleteCharactersInRange(NSMakeRange(i + 1, nsCount - i - 1))
            }
            if i > 0 {
                letter.deleteCharactersInRange(NSMakeRange(0, i))
            }

            if letter.string == "\n" {
                current.appendAttributedString(letter)
                startNewString = true
            }
            else {
                if !startNewString {
                    hasLetters = true
                }
                else if hasLetters {
                    strings.append(current)
                    current = NSMutableAttributedString()
                }
                current.appendAttributedString(letter)
                startNewString = false
            }
        }
        if count(current.string) > 0 {
            strings.append(current)
        }
        return strings
    }

    public static func style(text: String, _ addlAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs(addlAttrs))
    }

    public static func parse(input: String) -> NSAttributedString? {
        if let tag = Tag(input: input) {
            return tag.makeEditable()
        }
        return nil
    }

    public static func render(input: NSAttributedString) -> String {
        var output = ""
        input.enumerateAttributesInRange(NSRange(location: 0, length: input.length), options: nil) { (attrs, range, stopPtr) in
            var tags = [String]()
            if let underlineStyle = attrs[NSUnderlineStyleAttributeName] as? Int
            where underlineStyle == NSUnderlineStyle.StyleSingle.rawValue {
                tags.append("u")
            }

            if let font = attrs[NSFontAttributeName] as? UIFont {
                if font.fontName == UIFont.typewriterEditorBoldFont(12).fontName {
                    tags.append("strong")
                }
                else if font.fontName == UIFont.typewriterEditorBoldItalicFont(12).fontName {
                    tags.append("strong")
                    tags.append("em")
                }
                else if font.fontName == UIFont.typewriterEditorItalicFont(12).fontName {
                    tags.append("em")
                }
            }

            for tag in tags {
                output += "<\(tag)>"
            }
            output += (input.string as NSString).substringWithRange(range).entitiesEncoded()
            for tag in tags.reverse() {
                output += "</\(tag)>"
            }
        }
        return output
    }
}
