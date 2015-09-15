//
//  ElloNetworkError.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

let ElloNetworkErrorVersion = 1

public class ElloNetworkError: JSONAble {

    public enum CodeType: String {
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

    public let attrs: [String:[String]]?
    public let code: CodeType
    public let detail: String?
    public let messages: [String]?
    public let status: String?
    public let title: String

    init(attrs: [String:[String]]?,
        code: CodeType,
        detail: String?,
        messages: [String]?,
        status: String?,
        title: String )
    {
        self.attrs = attrs
        self.code = code
        self.detail = detail
        self.messages = messages
        self.status = status
        self.title = title
        super.init(version: ElloNetworkErrorVersion)
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.attrs = decoder.decodeOptionalKey("attrs")
        self.code = decoder.decodeKey("code")
        self.detail = decoder.decodeOptionalKey("detail")
        self.messages = decoder.decodeOptionalKey("messages")
        self.status = decoder.decodeOptionalKey("status")
        self.title = decoder.decodeKey("title")
        super.init(coder: aDecoder)
    }

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        let title = json["title"].stringValue
        var codeType = CodeType.unknown
        if let actualCode = ElloNetworkError.CodeType(rawValue: json["code"].stringValue) {
            codeType = actualCode
        }
        let detail = json["detail"].string
        let status = json["status"].string
        let messages = json["messages"].object as? [String]
        let attrs = json["attrs"].object as? [String:[String]]

        return ElloNetworkError(
            attrs: attrs,
            code: codeType,
            detail: detail,
            messages: messages,
            status: status,
            title: title
        )
    }
}
