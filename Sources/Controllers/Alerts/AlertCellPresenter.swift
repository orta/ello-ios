//
//  AlertCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct AlertCellPresenter {
    let action: AlertAction
    let textAlignment: NSTextAlignment

    func configureCell(cell: UITableViewCell) {
        let alertCell = cell as! AlertCell

        switch action.style {
        case .Light: configureForLightAction(alertCell)
        case .Dark: configureForDarkAction(alertCell)
        }
    }

    func configureForLightAction(cell: AlertCell) {
        cell.label.setLabelText(action.title, color: UIColor.grey6(), alignment: textAlignment)
        cell.background.backgroundColor = UIColor.greyE5()
    }

    func configureForDarkAction(cell: AlertCell) {
        cell.label.setLabelText(action.title, alignment: textAlignment)
        cell.background.backgroundColor = UIColor.blackColor()
    }
}
