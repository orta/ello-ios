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
        return "ResponseConfig: \r\tnextQueryItems: \(nextQueryItems) \r\tprevQueryItems: \(prevQueryItems) \r\ttotalPages: \(totalPages) \r\ttotalCount: \(totalCount) \r\ttotalPagesRemaining: \(totalPagesRemaining)"
    }
    var nextQueryItems: [AnyObject]?
    var prevQueryItems: [AnyObject]?
    var totalCount: String?
    var totalPages: String?
    var totalPagesRemaining: String?

    init() {}
}
