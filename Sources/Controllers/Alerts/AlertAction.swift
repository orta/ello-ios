//
//  AlertAction.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public typealias AlertHandler = ((AlertAction) -> Void)?
public typealias AlertCellConfigClosure = (
    cell: AlertCell,
    type: AlertType,
    action: AlertAction,
    textAlignment: NSTextAlignment
) -> Void

public enum ActionStyle {
    case White
    case Light
    case Dark
    case OKCancel
    case URLInput
}

public struct AlertAction {
    public let title: String
    public let style: ActionStyle
    public let handler: AlertHandler

    public var isInput: Bool {
        switch style {
        case .URLInput, .OKCancel:
            return true
        default:
            return false
        }
    }

    public init(title: String, style: ActionStyle, handler: AlertHandler = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    public var configure: AlertCellConfigClosure {
        switch style {
        case .White:
            return AlertCellPresenter.configureForWhiteAction
        case .Light:
            return AlertCellPresenter.configureForLightAction
        case .Dark:
            return AlertCellPresenter.configureForDarkAction
        case .OKCancel:
            return AlertCellPresenter.configureForOKCancelAction
        case .URLInput:
            return AlertCellPresenter.configureForURLAction
        }
    }

}
