//
//  AutoCompleteResult.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Crashlytics
import SwiftyJSON

let AutoCompleteResultVersion: Int = 1

@objc(AutoCompleteResult)
public final class AutoCompleteResult: JSONAble {

    public var url: NSURL?
    public var name: String?

    // MARK: Initialization

    public init(name: String?) {
        self.name = name
        super.init(version: AutoCompleteResultVersion)
    }

    public convenience init(name: String, url: String) {
        self.init(name: name)
        self.url = NSURL(string: url)
    }

    // MARK: NSCoding
    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.url = decoder.decodeOptionalKey("url")
        self.name = decoder.decodeOptionalKey("name")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(url, forKey: "url")
        coder.encodeObject(name, forKey: "name")
        super.encodeWithCoder(coder.coder)
    }

    // MARK: JSONAble

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.AutoCompleteResultFromJSON.rawValue)
        let result = AutoCompleteResult(name: json["name"].string)
        if let imageUrl = json["image_url"].string,
            url = NSURL(string: imageUrl)
        {
            result.url = url
        }
        return result
    }
}
