//
//  DrawerCellPresenter.swift
//  Ello
//
//  Created by Sean on 6/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct DrawerCellPresenter {

    public static func configure(cell: DrawerCell, item: DrawerItem) {
        switch item.type {
        case .Version:
            cell.label.font = UIFont.defaultFont(12)
            cell.label.textColor = .greyA()
            cell.line.hidden = true
        default:
            cell.label.font = UIFont.defaultFont()
            cell.label.textColor = .whiteColor()
            cell.line.hidden = false
        }

        cell.label.text = item.name
        cell.selectionStyle = .None
    }
}
