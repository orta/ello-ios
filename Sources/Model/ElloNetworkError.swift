//
//  ElloNetworkError.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON


struct ElloNetworkError {
    
    enum CodeType: String {
        case blacklisted = "blacklisted"
        case invalidRequest = "invalid_request"
        case invalidResource = "invalid_resource"
        case invalidVersion = "invalid_version"
        case lockedOut = "locked_out"
        case missingParam = "missing_param"
        case noEndpoint = "no_endpoint"
        case notFound = "not_found"
        case notValid = "not_valid"
        case rateLimited = "rate_limited"
        case serverError = "server_error"
        case timeout = "timeout"
        case unauthenticated = "unauthenticated"
        case unauthorized = "unauthorized"
        case unavailable = "unavailable"
        case unknown = "unknown"
    }

    let attrs: [String:[String]]?
    let code: CodeType
    let detail: String?
    let messages: [String]?
    let status: String?
    let title: String

}