//
//  AlertAction.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public typealias AlertHandler = ((AlertAction) -> Void)?

public enum ActionStyle {
    case White
    case Light
    case Dark
}

public struct AlertAction {
    public let title: String
    public let icon: UIImage?
    public let style: ActionStyle
    public let handler: AlertHandler

    public init(title: String, style: ActionStyle, handler: AlertHandler) {
        self.title = title
        self.icon = nil
        self.style = style
        self.handler = handler
    }

    public init(title: String, icon: UIImage?, style: ActionStyle, handler: AlertHandler) {
        self.title = title
        self.icon = icon
        self.style = style
        self.handler = handler
    }
}
