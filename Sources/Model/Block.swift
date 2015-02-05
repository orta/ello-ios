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
    
    class func blocks(json:JSON, assets:[String: AnyObject]?) -> [Block] {
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
                let assetId = data["asset_id"] as? String

                let imageBlock = ImageBlock(alt: alt, assetId: assetId, url: NSURL(string: url)!)

                if let assets = assets {
                    if let assetId = assetId {
                        if let attachment = assets[assetId]?["attachment"] as? [String:AnyObject] {
                            let hdpi = attachment["hdpi"] as? [String:AnyObject]
                            if let hdpi = hdpi {
                                let hdpiAttachment =
                                ImageAttachment(
                                    url: NSURL(string: hdpi["url"] as String),
                                    height: hdpi["metadata"]?["height"] as? Int,
                                    width: hdpi["metadata"]?["width"] as? Int,
                                    imageType: hdpi["metadata"]?["type"] as? String,
                                    size: hdpi["metadata"]?["size"] as? Int)
                                imageBlock.hdpi = hdpiAttachment
                            }

                            let xxhdpi = attachment["xxhdpi"] as? [String:AnyObject]

                            if let xxhdpi = xxhdpi {
                                let xxhdpiAttachment =
                                ImageAttachment(
                                    url: NSURL(string: xxhdpi["url"] as String),
                                    height: xxhdpi["metadata"]?["height"] as? Int,
                                    width: xxhdpi["metadata"]?["width"] as? Int,
                                    imageType: xxhdpi["metadata"]?["type"] as? String,
                                    size: xxhdpi["metadata"]?["size"] as? Int)
                                imageBlock.xxhdpi = xxhdpiAttachment
                            }
                        }
                    }
                }

                return imageBlock
            case .Unknown:
                return UnknownBlock()
            }
        }
    }
}

struct ImageAttachment {
    let url: NSURL?
    let height: Int?
    let width: Int?
    let imageType: String?
    let size: Int?
}

class UnknownBlock : Block {
    init() {
        super.init(kind: Block.Kind.Unknown)
    }
}

class ImageBlock : Block {
    let assetId:String?
    let alt:String
    let url:NSURL?
    var hdpi:ImageAttachment?
    var xxhdpi:ImageAttachment?
    
    init(alt: String, assetId: String?, url:NSURL?) {
        self.assetId = assetId
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