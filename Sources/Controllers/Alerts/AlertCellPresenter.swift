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
        buttonCell.label.text = action.title

        switch action.style {
        case .Light: configureForLightAction(buttonCell)
        case .Dark: configureForDarkAction(buttonCell)
        }
    }

    func configureForLightAction(cell: AlertCell) {
        cell.background.backgroundColor = UIColor.greyE5()
        cell.label.textColor = UIColor.grey6()
    }

    func configureForDarkAction(cell: AlertCell) {
        cell.background.backgroundColor = UIColor.blackColor()
        cell.label.textColor = UIColor.whiteColor()
    }
}
