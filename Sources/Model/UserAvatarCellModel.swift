//
//  UserAvatarCellModel.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

let UserAvatarCellModelVersion = 1

@objc(UserAvatarCellModel)
public final class UserAvatarCellModel: JSONAble {

    public let icon: Interface.Image
    public let seeMoreTitle: String
    public let indexPath: NSIndexPath
    public var endpoint: ElloAPI?
    public var users: [User]?

    public var hasUsers: Bool {
        if let arr = users {
            return arr.count > 0
        }
        return false
    }

    public init(icon: Interface.Image, seeMoreTitle: String, indexPath: NSIndexPath) {
        self.icon = icon
        self.seeMoreTitle = seeMoreTitle
        self.indexPath = indexPath
        super.init(version: UserAvatarCellModelVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.icon = decoder.decodeKey("icon")
        self.seeMoreTitle = decoder.decodeKey("seeMoreTitle")
        self.indexPath = decoder.decodeKey("indexPath")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(icon, forKey: "icon")
        coder.encodeObject(seeMoreTitle, forKey: "seeMoreTitle")
        coder.encodeObject(indexPath, forKey: "indexPath")
        super.encodeWithCoder(coder.coder)
    }

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return UserAvatarCellModel(
            icon: Interface.Image(rawValue: (data["icon"] as? String) ?? "hearts")!,
            seeMoreTitle: (data["seeMoreTitle"] as? String) ?? "",
            indexPath: (data["indexPath"] as? NSIndexPath) ?? NSIndexPath(forItem: 0, inSection: 0)
        )
    }

}
