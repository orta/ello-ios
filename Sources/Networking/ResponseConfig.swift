//
//  ResponseConfig.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class ResponseConfig: CustomStringConvertible {
    public var description: String {
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
        return descripArray.joinWithSeparator("\r\t")
    }
    public var nextQueryItems: [AnyObject]? // before (older)
    public var prevQueryItems: [AnyObject]? // after (newer)
    public var firstQueryItems: [AnyObject]? // first page
    public var lastQueryItems: [AnyObject]? // last page
    public var totalCount: String?
    public var totalPages: String?
    public var totalPagesRemaining: String?
    public var statusCode: Int?
    public var lastModified: String?

    public init() {}

    public func isOutOfData() -> Bool {

        return totalPagesRemaining == "0"
            || totalPagesRemaining == nil
            || nextQueryItems?.count == 0
            || nextQueryItems == nil
    }
}

