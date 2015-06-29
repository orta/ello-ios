//
//  UserAvatarCellModel.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let UserAvatarCellModelVersion = 1
public final class UserAvatarCellModel: JSONAble {

    public let icon: String
    public let endpoint: ElloAPI
    public var users: [User]?

    public var hasUsers: Bool {
        if let arr = users {
            return arr.count > 0
        }
        return false
    }

    public init(icon: String, endpoint: ElloAPI) {
        self.icon = icon
        self.endpoint = endpoint
        super.init(version: UserAvatarCellModelVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.icon = decoder.decodeKey("icon")
        self.endpoint = decoder.decodeKey("endpoint")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(icon, forKey: "icon")
        coder.encodeObject(endpoint, forKey: "endpoint")
        super.encodeWithCoder(coder.coder)
    }

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return UserAvatarCellModel(
            icon: (data["icon"] as? String) ?? "hearts_normal.svg",
            endpoint: (data["endpoint"] as? ElloAPI) ?? ElloAPI.PostDetail(postParam: "")
        )
    }

}
