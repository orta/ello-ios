//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

typealias FromJSONClosure = (data: [String:AnyObject]) -> JSONAble

protocol JSONAble {
    class func fromJSON(data:[String: AnyObject]) -> JSONAble
}
