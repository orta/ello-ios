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
//            println(contentDict)
            let kind = Block.Kind(rawValue: contentDict["kind"] as String) ?? Block.Kind.Unknown
            let data = contentDict["data"]
            switch kind {
            case .Text:
                let data = data as String
                return TextBlock(content: data)
            case .Image:
                let data = data as [String:AnyObject]
                let assetId = data["asset_id"] as Int
                let via = data["via"] as String
                let alt = data["alt"] as? String ?? ""
                let url = data["url"] as String
                return ImageBlock(assetId: assetId, via: via, alt: alt, url: NSURL(string: url)!)
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
    let assetId:Int
    let via:String
    let alt:String
    let url:NSURL?
    
    init(assetId: Int, via: String, alt: String, url:NSURL?) {
        self.assetId = assetId
        self.via = via
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