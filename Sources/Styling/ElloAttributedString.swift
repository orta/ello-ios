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

    public static func style(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
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
                if font.fontName == UIFont.typewriterBoldFont(12).fontName {
                    tags.append("strong")
                }
                else if font.fontName == UIFont.typewriterBoldItalicFont(12).fontName {
                    tags.append("strong")
                    tags.append("em")
                }
                else if font.fontName == UIFont.typewriterItalicFont(12).fontName {
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
