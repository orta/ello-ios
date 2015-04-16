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
        super.init()
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.label = decoder.decodeKey("label")
        self.settings = decoder.decodeKey("settings")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(label, forKey: "label")
        encoder.encodeObject(settings, forKey: "settings")
        super.encodeWithCoder(encoder)
    }
}

extension DynamicSettingCategory {
    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> DynamicSettingCategory {
        let json = JSON(data)
        let label = json["label"].stringValue
        let settings: [DynamicSetting] = json["items"].arrayValue.map { DynamicSetting.fromJSON($0.object as! [String: AnyObject]) }

        return DynamicSettingCategory(label: label, settings: settings)
    }
}
