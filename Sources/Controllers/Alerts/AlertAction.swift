//
//  AlertAction.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

enum ActionStyle {
    case Light
    case Dark
}

struct AlertAction {
    let title: String
    let style: ActionStyle
    let handler: ((AlertAction) -> ())?
}
