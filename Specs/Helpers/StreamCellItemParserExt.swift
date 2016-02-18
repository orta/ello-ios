//
//  StreamCellItemParserExt.swift
//  Ello
//
//  Created by Colin Gray on 7/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello


extension StreamCellItemParser {

    func parseAllForTesting(items: [JSONAble]) -> [StreamCellItem] {
        var retItems = [StreamCellItem]()
        for item in items {
            if let post = item as? Post {
                retItems += testingPostCellItems([post], streamKind: .Following)
            }
            if let comment = item as? ElloComment {
                retItems += testingCommentCellItems([comment])
            }
            if let notification = item as? Notification {
                retItems += testingNotificationCellItems([notification])
            }
            if let user = item as? User {
                retItems += testingUserCellItems([user])
            }
        }
        return retItems
    }

}
