//
//  NotificationCellItemParser.swift
//  Ello
//
//  Created by Colin Gray on 2/13/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct NotificationCellItemParser {

    func cellItems(notifications:[Notification]) -> [StreamCellItem] {
        return map(notifications) { notification in
            return StreamCellItem(
                jsonable: notification,
                type: .Notification,
                data: nil,
                oneColumnCellHeight: 107.0,
                multiColumnCellHeight: 49.0,
                isFullWidth: false
            )
        }
    }

}