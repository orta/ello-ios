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
    // optional avatar
    public var large: Attachment?
    public var regular: Attachment?
    public var small: Attachment?
    // computed
    var isGif: Bool {
        return self.optimized?.type == "image/gif"
    }

	public var oneColumnAttachment: Attachment? {
        return self.hdpi
    }

    public var gridLayoutAttachment: Attachment? {
        return self.mdpi
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
        // required
        self.id = decoder.decodeKey("id")
        // optional
        self.optimized = decoder.decodeOptionalKey("optimized")
        self.smallScreen = decoder.decodeOptionalKey("smallScreen")
        self.ldpi = decoder.decodeOptionalKey("ldpi")
        self.mdpi = decoder.decodeOptionalKey("mdpi")
        self.hdpi = decoder.decodeOptionalKey("hdpi")
        self.xhdpi = decoder.decodeOptionalKey("xhdpi")
        self.xxhdpi = decoder.decodeOptionalKey("xxhdpi")
        self.original = decoder.decodeOptionalKey("original")
        // optional avatar
        self.large = decoder.decodeOptionalKey("large")
        self.regular = decoder.decodeOptionalKey("regular")
        self.small = decoder.decodeOptionalKey("small")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // required
        encoder.encodeObject(id, forKey: "id")
        // optional
        encoder.encodeObject(optimized, forKey: "optimized")
        encoder.encodeObject(smallScreen, forKey: "smallScreen")
        encoder.encodeObject(ldpi, forKey: "ldpi")
        encoder.encodeObject(mdpi, forKey: "mdpi")
        encoder.encodeObject(hdpi, forKey: "hdpi")
        encoder.encodeObject(xhdpi, forKey: "xhdpi")
        encoder.encodeObject(xxhdpi, forKey: "xxhdpi")
        encoder.encodeObject(original, forKey: "original")
        // optional avatar
        encoder.encodeObject(large, forKey: "large")
        encoder.encodeObject(regular, forKey: "regular")
        encoder.encodeObject(small, forKey: "small")
        super.encodeWithCoder(encoder)
    }
    
// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        return parseAsset(json["id"].stringValue, node: data["attachment"] as? [String: AnyObject])
    }

    class public func parseAsset(id: String, node: [String: AnyObject]?) -> Asset {
        var asset = Asset(id: id)
        // optional
        if let optimized = node?["optimized"] as? [String: AnyObject] {
            asset.optimized = Attachment.fromJSON(optimized) as? Attachment
        }
        if let smallScreen = node?["small_screen"] as? [String: AnyObject] {
            asset.smallScreen = Attachment.fromJSON(smallScreen) as? Attachment
        }
        if let ldpi = node?["ldpi"] as? [String: AnyObject] {
            asset.ldpi = Attachment.fromJSON(ldpi) as? Attachment
        }
        if let mdpi = node?["mdpi"] as? [String: AnyObject] {
            asset.mdpi = Attachment.fromJSON(mdpi) as? Attachment
        }
        if let hdpi = node?["hdpi"] as? [String: AnyObject] {
            asset.hdpi = Attachment.fromJSON(hdpi) as? Attachment
        }
        if let xhdpi = node?["xhdpi"] as? [String: AnyObject] {
            asset.xhdpi = Attachment.fromJSON(xhdpi) as? Attachment
        }
        if let xxhdpi = node?["xxhdpi"] as? [String: AnyObject] {
            asset.xxhdpi = Attachment.fromJSON(xxhdpi) as? Attachment
        }
        if let original = node?["original"] as? [String: AnyObject] {
            asset.original = Attachment.fromJSON(original) as? Attachment
        }
        // optional avatar
        if let large = node?["large"] as? [String: AnyObject] {
            asset.large = Attachment.fromJSON(large) as? Attachment
        }
        if let regular = node?["regular"] as? [String: AnyObject] {
            asset.regular = Attachment.fromJSON(regular) as? Attachment
        }
        if let small = node?["small"] as? [String: AnyObject] {
            asset.small = Attachment.fromJSON(small) as? Attachment
        }
        return asset
    }
}
