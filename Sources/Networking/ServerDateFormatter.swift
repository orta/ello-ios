//
//  ServerDateFormatter.swift
//  Ello
//
//  Created by Sean Dougherty on 12/3/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

let ServerDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return formatter
}()

let HTTPDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return formatter
    }()

public extension NSString {

    func toNSDate() -> NSDate? {
        return ServerDateFormatter.dateFromString(self as String)
    }

}

public extension NSDate {

    func toNSString() -> NSString {
        return ServerDateFormatter.stringFromDate(self)
    }

    func toHTTPDate() -> NSString {
        return HTTPDateFormatter.stringFromDate(self)
    }

}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

public extension NSDate {
    var isInPast: Bool {
        let now = NSDate()
        return self.compare(now) == NSComparisonResult.OrderedAscending
    }
}
