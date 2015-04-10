//
//  DynamicSettingCategory.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyJSON

public final class DynamicSettingCategory: JSONAble {
    public let label: String
    public let settings: [DynamicSetting]

    public init(label: String, settings: [DynamicSetting]) {
        self.label = label
        self.settings = settings
    }
}

extension DynamicSettingCategory {
    override public class func fromJSON(data: [String: AnyObject]) -> DynamicSettingCategory {
        let json = JSON(data)
        let label = json["label"].stringValue
        let settings: [DynamicSetting] = json["items"].arrayValue.map { DynamicSetting.fromJSON($0.object as! [String: AnyObject]) }

        return DynamicSettingCategory(label: label, settings: settings)
    }
}
