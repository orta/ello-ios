//
//  AutoCompleteCellPresenter.swift
//  Ello
//
//  Created by Sean on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct AutoCompleteCellPresenter {

    public static func configure(cell: AutoCompleteCell, item: AutoCompleteItem) {
        cell.name.font = UIFont.typewriterFont(12)
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
        cell.avatar.setAvatarURL(item.result.url)
    }
}
