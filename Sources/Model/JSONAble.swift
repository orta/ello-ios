//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

public typealias FromJSONClosure = (data: [String: AnyObject]) -> JSONAble

public class JSONAble: NSObject {
//    // active record
//    public let id: String
//    public let createdAt: NSDate
//
//    public init(id: String, createdAt: NSDate) {
//        self.id = id
//        self.createdAt = createdAt
//        super.init()
//    }

    public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        return JSONAble()
    }
}
