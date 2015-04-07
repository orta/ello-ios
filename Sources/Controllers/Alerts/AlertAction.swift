//
//  AlertAction.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public enum ActionStyle {
    case Light
    case Dark
}

public struct AlertAction {
    public let title: String
    public let style: ActionStyle
    public let handler: ((AlertAction) -> ())?
}
