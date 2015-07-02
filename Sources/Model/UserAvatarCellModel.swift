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
    public let seeMoreTitle: String
    public var endpoint: ElloAPI?
    public var users: [User]?

    public var hasUsers: Bool {
        if let arr = users {
            return arr.count > 0
        }
        return false
    }

    public init(icon: String, seeMoreTitle: String) {
        self.icon = icon
        self.seeMoreTitle = seeMoreTitle
        super.init(version: UserAvatarCellModelVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.icon = decoder.decodeKey("icon")
        self.seeMoreTitle = decoder.decodeKey("seeMoreTitle")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(icon, forKey: "icon")
        coder.encodeObject(seeMoreTitle, forKey: "seeMoreTitle")
        super.encodeWithCoder(coder.coder)
    }

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return UserAvatarCellModel(
            icon: (data["icon"] as? String) ?? "hearts_normal.svg",
            seeMoreTitle: (data["seeMoreTitle"] as? String) ?? ""
        )
    }

}
