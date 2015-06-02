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
        case .Plain:
            cell.label.font = UIFont.typewriterFont(12)
            cell.label.textColor = .greyA()
            cell.line.hidden = true
        default:
            cell.label.font = UIFont.regularBoldFont(18)
            cell.label.textColor = .blackColor()
            cell.line.hidden = false
        }
        cell.line.backgroundColor = .greyF1()
        cell.label.text = item.name
        cell.selectionStyle = .None
    }
}
