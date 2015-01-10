//
//  ServerDateFormatter.swift
//  Ello
//
//  Created by Sean Dougherty on 12/3/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

let ServerDateFormatter = NSDateFormatter()

extension NSString {

    func toNSDate() -> NSDate? {
        ServerDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        ServerDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return ServerDateFormatter.dateFromString(self)
    }

}
