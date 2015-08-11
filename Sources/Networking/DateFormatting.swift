//
//  DateFormatting.swift
//  Ello
//
//  Created by Sean Dougherty on 12/3/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public let ServerDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return formatter
}()

public let HTTPDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return formatter
}()
