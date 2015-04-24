//
//  EmbedRegion.swift
//  Ello
//
//  Created by Ryan Boyajian on 4/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let EmbedRegionVersion = 1

public enum EmbedType: String {
    case Codepen = "codepen"
    case Dailymotion = "dailymotion"
    case Mixcloud = "mixcloud"
    case Soundcloud = "soundcloud"
    case Youtube = "youtube"
    case Vimeo = "vimeo"
    case Unknown = "unknown"
}

public final class EmbedRegion: JSONAble, Regionable {
    public let version = EmbedRegionVersion
    public var isRepost: Bool = false
    
    // active record
    public let id: String
    // required
    public let service: EmbedType
    public let url: NSURL
    public let thumbnailSmallUrl: NSURL
    public let thumbnailLargeUrl: NSURL
    // computed
    public var isAudioEmbed: Bool {
        return service == EmbedType.Mixcloud || service == EmbedType.Soundcloud
    }

    // MARK: Initialization

    public init(
        id: String,
        service: EmbedType,
        url: NSURL,
        thumbnailSmallUrl: NSURL,
        thumbnailLargeUrl: NSURL
        )
    {
        self.id = id
        self.service = service
        self.url = url
        self.thumbnailSmallUrl = thumbnailSmallUrl
        self.thumbnailLargeUrl = thumbnailLargeUrl
        super.init()
    }

    // MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        // required
        self.isRepost = decoder.decodeKey("isRepost")
        let serviceRaw: String = decoder.decodeKey("serviceRaw")
        self.service = EmbedType(rawValue: serviceRaw) ?? EmbedType.Unknown
        self.url = decoder.decodeKey("url")
        self.thumbnailSmallUrl = decoder.decodeKey("thumbnailSmallUrl")
        self.thumbnailLargeUrl = decoder.decodeKey("thumbnailLargeUrl")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        // required
        encoder.encodeBool(isRepost, forKey: "isRepost")
        encoder.encodeObject(service.rawValue, forKey: "serviceRaw")
        encoder.encodeObject(url, forKey: "url")
        encoder.encodeObject(thumbnailSmallUrl, forKey: "thumbnailSmallUrl")
        encoder.encodeObject(thumbnailLargeUrl, forKey: "thumbnailLargeUrl")
        super.encodeWithCoder(encoder)
    }

    // MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        // create region
        var embedRegion = EmbedRegion(
            id: json["data"]["id"].stringValue,
            service: EmbedType(rawValue: json["data"]["service"].stringValue) ?? .Unknown,
            url: NSURL(string: json["data"]["url"].stringValue)!,
            thumbnailSmallUrl: NSURL(string: json["data"]["thumbnail_small_url"].stringValue)!,
            thumbnailLargeUrl: NSURL(string: json["data"]["thumbnail_large_url"].stringValue)!
        )
        return embedRegion
    }

// MARK: Regionable

    public var kind:String { return RegionKind.Embed.rawValue }
    
    public func coding() -> NSCoding {
        return self
    }

    public func toJSON() -> [String: AnyObject] {
        if let url : String = self.url.absoluteString {
            return [
                "kind": self.kind,
                "data": [
                    "url": url
                ],
            ]
        }
        else {
            return [
                "kind": self.kind,
                "data": [:]
            ]
        }
    }
}
