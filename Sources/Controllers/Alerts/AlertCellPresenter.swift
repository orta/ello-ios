//
//  AlertCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct AlertCellPresenter {
    let reuseIdentifier = "AlertCell"
    let action: AlertAction

    func configureCell(cell: UITableViewCell) {
        let buttonCell = cell as! AlertCell

        switch action.style {
        case .Light: configureForLightAction(buttonCell)
        case .Dark: configureForDarkAction(buttonCell)
        }
    }

    func configureForLightAction(cell: AlertCell) {
        cell.label.setLabelText(action.title, color: UIColor.grey6())
        cell.background.backgroundColor = UIColor.greyE5()
    }

    func configureForDarkAction(cell: AlertCell) {
        cell.label.setLabelText(action.title)
        cell.background.backgroundColor = UIColor.blackColor()
    }
}
