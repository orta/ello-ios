//
//  StringExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

private let salt = "***REMOVED***"

extension String {

    func stripHTML() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
    }

    var SHA1String: String? {
        if let data = (salt + self).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            
            var digest = [UInt8](count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
            let output = NSMutableString(capacity: Int(CC_SHA512_DIGEST_LENGTH));
            for byte in digest {
                output.appendFormat("%02x", byte);
            }
            
            return output
        }
        return .None
    }
}