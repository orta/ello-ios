//
//  ElloAttributedString.swift
//  Ello
//
//  Created by Colin Gray on 2/27/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct ElloAttributedString {
    static func attrs(_ addlAttrs : [String : AnyObject] = [:]) -> [NSObject : AnyObject] {
        let attrs : [String : AnyObject] = [
            NSFontAttributeName : UIFont.typewriterFont(12),
            NSForegroundColorAttributeName : UIColor.blackColor(),
        ]
        return attrs + addlAttrs
    }

    static func linkAttrs() -> [NSObject : AnyObject] {
        return attrs([
            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue,
        ])
    }

    static func style(text : String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
    }
}
