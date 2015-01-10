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
    
    enum CodeType: String {
        case blacklisted = "blacklisted"
        case rateLimited = "rate_limited"
        case timeout = "timeout"
        case unavailable = "unavailable"
        case noEndpoint = "no_endpoint"
        case invalidVersion = "invalid_version"
        case unauthenticated = "unauthenticated"
        case unauthorized = "unauthorized"
        case notFound = "not_found"
        case missingParam = "missing_param"
        case invalidResource = "invalid_resource"
        case serverError = "server_error"
        case lockedOut = "locked_out"
        case notValid = "not_valid"
        case invalidRequest = "invalid_request"
        case unknown = "unknown"
    }

    let errors: [String:AnyObject]
    let title: String
    let code: CodeType
    let detail: String?
    let status: String?
    let messages: [String]?
    let attrs: [String:[String]]?

    init(errors: [String:AnyObject], title:String, code:String, detail:String?, status:String?, messages:[String]?, attrs:[String:[String]]?) {
        self.errors = errors
        self.code = CodeType(rawValue: code) ?? CodeType.unknown
        self.title = title
        self.detail = detail
        self.status = status
        self.messages = messages
        self.attrs = attrs
    }
    
    override class func fromJSON(data:[String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
        let json = JSON(data)
        let errors = json["errors"].object as [String:AnyObject]
        let title = errors["title"] as String
        let code = errors["code"] as? String ?? CodeType.unknown.rawValue
        let detail = errors["detail"] as? String
        let status = errors["status"] as? String
        let messages = errors["messages"] as? [String]
        let attrs = errors["attrs"] as? [String:[String]]
        
        return ElloNetworkError(errors: errors, title:title, code: code, detail: detail, status: status, messages: messages, attrs: attrs)
    }
}