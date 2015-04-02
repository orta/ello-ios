//
//  ResponseConfig.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class ResponseConfig: Printable {
    var description: String {
        let descripArray = [
            "ResponseConfig:",
            "nextQueryItems: \(nextQueryItems)",
            "prevQueryItems: \(prevQueryItems)",
            "firstQueryItems: \(firstQueryItems)",
            "lastQueryItems: \(lastQueryItems)",
            "totalPages: \(totalPages)",
            "totalCount: \(totalCount)",
            "totalPagesRemaining: \(totalPagesRemaining)"
        ]
        return "\r\t".join(descripArray)
    }
    var nextQueryItems: [AnyObject]? // before (older)
    var prevQueryItems: [AnyObject]? // after (newer)
    var firstQueryItems: [AnyObject]? // first page
    var lastQueryItems: [AnyObject]? // last page
    var totalCount: String?
    var totalPages: String?
    var totalPagesRemaining: String?

    init() {}

    func isOutOfData() -> Bool {
        return totalPagesRemaining == "0"
            || totalPagesRemaining == nil
            || nextQueryItems.map(count) == 0
            || nextQueryItems == nil
    }
}
