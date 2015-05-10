//
//  DynamicSetting.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON

let DynamicSettingVersion = 1

public final class DynamicSetting: JSONAble {
    public let label: String
    public let key: String
    public let info: String?
    public let linkLabel: String?
    public let linkURL: NSURL?

    public init(label: String, key: String, info: String?, linkLabel: String?, linkURL: NSURL?) {
        self.label = label
        self.key = key
        self.info = info
        self.linkLabel = linkLabel
        self.linkURL = linkURL
        super.init(version: DynamicSettingVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.label = decoder.decodeKey("label")
        self.key = decoder.decodeKey("key")
        self.info = decoder.decodeOptionalKey("info")
        self.linkLabel = decoder.decodeOptionalKey("linkLabel")
        self.linkURL = decoder.decodeOptionalKey("linkURL")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(label, forKey: "label")
        encoder.encodeObject(key, forKey: "key")
        encoder.encodeObject(info, forKey: "info")
        encoder.encodeObject(linkLabel, forKey: "linkLabel")
        encoder.encodeObject(linkURL, forKey: "linkURL")
        super.encodeWithCoder(encoder)
    }
}

extension DynamicSetting {
    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> DynamicSetting {
        let json = JSON(data)
        let label = json["label"].stringValue
        let key = json["key"].stringValue
        let info = json["info"].string
        let linkLabel = json["link"]["label"].string
        let linkURL = json["link"]["url"].URL

        return DynamicSetting(label: label, key: key, info: info, linkLabel: linkLabel, linkURL: linkURL)
    }
}

public extension DynamicSetting {
    static var accountDeletionSetting: DynamicSetting {
        let label = NSLocalizedString("Delete Account", comment: "account deletion label")
        let info = NSLocalizedString("By deleting your account you remove your personal information from Ello. Your account cannot be restored.", comment: "By deleting your account you remove your personal information from Ello. Your account cannot be restored.")
        return DynamicSetting(label: label, key: "delete_account", info: info, linkLabel: .None, linkURL: .None)
    }
}
