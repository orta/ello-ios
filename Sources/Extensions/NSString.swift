//
//  NSString.swift
//  Ello
//
//  Created by Sean on 8/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public extension NSString {
    func toNSDate(formatter: NSDateFormatter = ServerDateFormatter) -> NSDate? {
        return formatter.dateFromString(self as String)
    }
}
