//
//  AlertCellPresenter.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

struct AlertCellPresenter {

    static func configureCell(alertCell: AlertCell, type: AlertType = .Normal) {
        alertCell.input.hidden = true
        alertCell.okButton.hidden = true
        alertCell.cancelButton.hidden = true
        alertCell.contentView.backgroundColor = type.backgroundColor
    }

    static func configureForWhiteAction(cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, color: UIColor.blackColor(), alignment: textAlignment)
        cell.background.backgroundColor = UIColor.whiteColor()
    }

    static func configureForLightAction(cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, color: UIColor.grey6(), alignment: textAlignment)
        cell.background.backgroundColor = UIColor.greyE5()
    }

    static func configureForDarkAction(cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.setLabelText(action.title, alignment: textAlignment)
        cell.background.backgroundColor = UIColor.blackColor()
    }

    static func configureForInputAction(cell: AlertCell, type: AlertType, action: AlertAction) {
        configureCell(cell, type: type)

        cell.input.hidden = false
        cell.input.placeholder = action.title

        cell.input.keyboardAppearance = .Dark
        cell.input.keyboardType = .Default
        cell.input.autocapitalizationType = .Sentences
        cell.input.autocorrectionType = .Default
        cell.input.spellCheckingType = .Default
        cell.input.keyboardAppearance = .Dark
        cell.input.enablesReturnKeyAutomatically = true
        cell.input.returnKeyType = .Default

        cell.background.backgroundColor = UIColor.whiteColor()
    }

    static func configureForURLAction(cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureForInputAction(cell, type: type, action: action)

        cell.input.keyboardAppearance = .Dark
        cell.input.keyboardType = .URL
        cell.input.autocapitalizationType = .None
        cell.input.autocorrectionType = .No
        cell.input.spellCheckingType = .No
    }

    static func configureForOKCancelAction(cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        cell.background.backgroundColor = UIColor.clearColor()
        cell.label.hidden = true
        cell.input.hidden = true
        cell.okButton.hidden = false
        cell.cancelButton.hidden = false
    }

}
