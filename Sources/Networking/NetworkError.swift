//
//  NetworkError.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

public let ElloErrorDomain = "co.ello.Ello"

public enum ElloErrorCode: Int {
    case ImageMapping = 0
    case JSONMapping
    case StringMapping
    case StatusCode
    case Data
    case NetworkFailure
}

extension NSError {

    class func networkError(error: AnyObject?, code: ElloErrorCode) -> NSError {
        var userInfo: [NSObject : AnyObject]?
        if let error: AnyObject = error {
            userInfo = [NSLocalizedFailureReasonErrorKey: error]
        }
        return NSError(domain: ElloErrorDomain, code: code.rawValue, userInfo: userInfo)
    }

}
