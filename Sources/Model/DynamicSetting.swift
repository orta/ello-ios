//
//  DynamicSetting.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON

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
    }
}

extension DynamicSetting {
    override public class func fromJSON(data: [String: AnyObject]) -> DynamicSetting {
        let json = JSON(data)
        let label = json["label"].stringValue
        let key = json["key"].stringValue
        let info = json["info"].string
        let linkLabel = json["link"]["label"].string
        let linkURL = json["link"]["url"].URL

        return DynamicSetting(label: label, key: key, info: info, linkLabel: linkLabel, linkURL: linkURL)
    }
}
