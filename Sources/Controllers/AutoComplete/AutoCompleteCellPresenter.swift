//
//  AutoCompleteCellPresenter.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AutoCompleteCellPresenter {

    public static func configure(cell: AutoCompleteCell, item: AutoCompleteItem) {
        cell.name.font = UIFont.defaultFont()
        cell.name.textColor = UIColor.whiteColor()
        cell.line.hidden = false
        cell.line.backgroundColor = UIColor.grey3()
        if let resultName = item.result.name {
            cell.name.text = item.type == .Emoji ? ":\(resultName):" : "@\(resultName)"
        }
        else {
            cell.name.text = ""
        }
        cell.selectionStyle = .None
        if let url = item.result.url {
            let user = User(id: NSUUID().UUIDString, href: "", username: item.result.name ?? "", name: "", experimentalFeatures: false, relationshipPriority: RelationshipPriority.None, postsAdultContent: false, viewsAdultContent: false, hasCommentingEnabled: true, hasSharingEnabled: true, hasRepostingEnabled: true, hasLovesEnabled: true)
            let asset = Asset(url: url)
            user.avatar = asset
            cell.avatar.setUser(user)
        }
        else {
            cell.avatar.setUser(nil)
        }
    }
}
