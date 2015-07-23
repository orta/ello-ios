//
//  AutoCompleteResult.swift
//  Ello
//
//  Created by Sean on 6/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

let AutoCompleteResultVersion: Int = 1

public final class AutoCompleteResult: JSONAble {

    public var url: NSURL?
    public var name: String?

    // MARK: Initialization

    public init() {
        super.init(version: AutoCompleteResultVersion)
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

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        var result = AutoCompleteResult()
        result.name = json["name"].string
        if let avatar = json["image_url"].string, let url = NSURL(string: avatar) {
            result.url = url
        }
        return result
    }
}
