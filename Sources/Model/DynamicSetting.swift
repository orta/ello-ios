//
//  DynamicSetting.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics
import SwiftyJSON

let DynamicSettingVersion = 1

@objc(DynamicSetting)
public final class DynamicSetting: JSONAble {
    public let label: String
    public let key: String
    public let dependentOn: [String]
    public let conflictsWith: [String]
    public let info: String?
    public let linkLabel: String?
    public let linkURL: NSURL?

    public init(label: String, key: String, dependentOn: [String], conflictsWith: [String], info: String?, linkLabel: String?, linkURL: NSURL?) {
        self.label = label
        self.key = key
        self.dependentOn = dependentOn
        self.conflictsWith = conflictsWith
        self.info = info
        self.linkLabel = linkLabel
        self.linkURL = linkURL
        super.init(version: DynamicSettingVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.label = decoder.decodeKey("label")
        self.key = decoder.decodeKey("key")
        self.dependentOn = decoder.decodeKey("dependentOn")
        self.conflictsWith = decoder.decodeKey("conflictsWith")
        self.info = decoder.decodeOptionalKey("info")
        self.linkLabel = decoder.decodeOptionalKey("linkLabel")
        self.linkURL = decoder.decodeOptionalKey("linkURL")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(label, forKey: "label")
        coder.encodeObject(key, forKey: "key")
        coder.encodeObject(dependentOn, forKey: "dependentOn")
        coder.encodeObject(conflictsWith, forKey: "conflictsWith")
        coder.encodeObject(info, forKey: "info")
        coder.encodeObject(linkLabel, forKey: "linkLabel")
        coder.encodeObject(linkURL, forKey: "linkURL")
        super.encodeWithCoder(coder.coder)
    }
}

extension DynamicSetting {
    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> DynamicSetting {
        var json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.DynamicSettingFromJSON.rawValue)
        let label = json["label"].stringValue
        let key = json["key"].stringValue

        let dependentOn: [String]
        if let jsonConflictsWith = json["dependent_on"].array {
            dependentOn = jsonConflictsWith.flatMap { $0.string }
        }
        else if key == "has_sharing_enabled" {
            dependentOn = ["is_public"]
        }
        else {
            dependentOn = []
        }

        let conflictsWith: [String] = json["conflicts_with"].array?.flatMap { $0.string } ?? []

        let info = json["info"].string
        let linkLabel = json["link"]["label"].string
        let linkURL = json["link"]["url"].URL

        return DynamicSetting(label: label, key: key, dependentOn: dependentOn, conflictsWith: conflictsWith, info: info, linkLabel: linkLabel, linkURL: linkURL)
    }
}

public extension DynamicSetting {
    static var accountDeletionSetting: DynamicSetting {
        let label = InterfaceString.Settings.DeleteAccount
        let info = InterfaceString.Settings.DeleteAccountExplanation
        return DynamicSetting(label: label, key: "delete_account", dependentOn: [], conflictsWith: [], info: info, linkLabel: .None, linkURL: .None)
    }
}
