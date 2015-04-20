//
//  Asset.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let AssetVersion = 1

public final class Asset: JSONAble {
    public let version = AssetVersion

    // active record
    public let id: String
    // optional
    public var optimized: Attachment?
    public var smallScreen: Attachment?
    public var ldpi: Attachment?
    public var mdpi: Attachment?
    public var hdpi: Attachment?
    public var xhdpi: Attachment?
    public var xxhdpi: Attachment?
    public var original: Attachment?
    // computed
    var isGif: Bool {
        return self.optimized?.type == "image/gif"
    }

// MARK: Initialization
    
    public init(id: String)
    {
        self.id = id
        super.init()
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.id = decoder.decodeKey("id")
        self.optimized = decoder.decodeOptionalKey("optimized")
        self.smallScreen = decoder.decodeOptionalKey("smallScreen")
        self.ldpi = decoder.decodeOptionalKey("ldpi")
        self.mdpi = decoder.decodeOptionalKey("mdpi")
        self.hdpi = decoder.decodeOptionalKey("hdpi")
        self.xhdpi = decoder.decodeOptionalKey("xhdpi")
        self.xxhdpi = decoder.decodeOptionalKey("xxhdpi")
        self.original = decoder.decodeOptionalKey("original")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {

        encoder.encodeObject(self.id, forKey: "id")
        encoder.encodeObject(optimized, forKey: "optimized")
        encoder.encodeObject(smallScreen, forKey: "smallScreen")
        encoder.encodeObject(ldpi, forKey: "ldpi")
        encoder.encodeObject(mdpi, forKey: "mdpi")
        encoder.encodeObject(hdpi, forKey: "hdpi")
        encoder.encodeObject(xhdpi, forKey: "xhdpi")
        encoder.encodeObject(xxhdpi, forKey: "xxhdpi")
        encoder.encodeObject(original, forKey: "original")
        super.encodeWithCoder(encoder)
    }
    
// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        let attachment = data["attachment"] as? [String:AnyObject]
        var asset = Asset(id: json["id"].stringValue)
        // optional
        if let optimized = attachment?["optimized"] as? [String: AnyObject] {
            asset.optimized = Attachment.fromJSON(optimized) as? Attachment
        }
        if let smallScreen = attachment?["small_screen"] as? [String: AnyObject] {
            asset.smallScreen = Attachment.fromJSON(smallScreen) as? Attachment
        }
        if let ldpi = attachment?["ldpi"] as? [String: AnyObject] {
            asset.ldpi = Attachment.fromJSON(ldpi) as? Attachment
        }
        if let mdpi = attachment?["mdpi"] as? [String: AnyObject] {
            asset.mdpi = Attachment.fromJSON(mdpi) as? Attachment
        }
        if let hdpi = attachment?["hdpi"] as? [String: AnyObject] {
            asset.hdpi = Attachment.fromJSON(hdpi) as? Attachment
        }
        if let xhdpi = attachment?["xhdpi"] as? [String: AnyObject] {
            asset.xhdpi = Attachment.fromJSON(xhdpi) as? Attachment
        }
        if let xxhdpi = attachment?["xxhdpi"] as? [String: AnyObject] {
            asset.xxhdpi = Attachment.fromJSON(xxhdpi) as? Attachment
        }
        if let original = attachment?["original"] as? [String: AnyObject] {
            asset.original = Attachment.fromJSON(original) as? Attachment
        }

        return asset
    }
}
