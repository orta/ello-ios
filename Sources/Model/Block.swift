//
//  Block.swift
//  Ello
//
//  Created by Sean on 1/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON


class Block {

    enum Kind: String {
        case Text = "text"
        case Image = "image"
        case Unknown = "Unknown"
    }
    
    let kind:Kind
    init(kind: Kind) {
        self.kind = kind
    }
    
    class func blocks(json:JSON) -> [Block] {
        let content = json["content"].object as [AnyObject]
        return content.map { (contentDict) -> Block in
            let kind = Block.Kind(rawValue: contentDict["kind"] as String) ?? Block.Kind.Unknown
            let data = contentDict["data"]
            switch kind {
            case .Text:
                let data = data as String
                return TextBlock(content: data)
            case .Image:
                let data = data as [String:AnyObject]
                let alt = data["alt"] as? String ?? ""
                let url = data["url"] as String
                return ImageBlock(alt: alt, url: NSURL(string: url)!)
            case .Unknown:
                return UnknownBlock()
            }
        }
    }
}

class UnknownBlock : Block {
    init() {
        super.init(kind: Block.Kind.Unknown)
    }
}

class ImageBlock : Block {
    let alt:String
    let url:NSURL?
    
    init(alt: String, url:NSURL?) {
        self.alt = alt
        self.url = url
        super.init(kind: Block.Kind.Image)
    }
}

class TextBlock : Block {
    let content:String
    
    init(content: String) {
        self.content = content
        super.init(kind: Block.Kind.Text)
    }
}