//
//  ElloNetworkError.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

class ElloNetworkError: JSONAble {
    dynamic let error: String
    dynamic let errorDescription: String
    dynamic let messages: [String]?
    let errors: [String:[String]]?

    init(error: String, errorDescription: String, messages: [String]?, errors: [String:[String]]? ) {
        self.error = error
        self.errorDescription = errorDescription
        self.messages = messages
        self.errors = errors
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let error = json["error"].stringValue
        let errorDescription = json["error_description"].stringValue
        let messages = json["messages"].object as? [String]
        let errors = json["errors"].object as? [String:[String]]
        return ElloNetworkError(error: error, errorDescription: errorDescription, messages: messages, errors:errors)
    }
}