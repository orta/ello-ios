//
//  ElloNetworkErrorExtensions.swift
//  Ello
//
//  Created by Sean on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ElloNetworkError: JSONAble {

    static func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let title = json["title"].stringValue
        let code = json["code"].string ?? CodeType.unknown.rawValue
        let detail = json["detail"].string
        let status = json["status"].string
        let messages = json["messages"].object as? [String]
        let attrs = json["attrs"].object as? [String:[String]]

        return ElloNetworkError(
            attrs: attrs,
            code: ElloNetworkError.CodeType(rawValue:code)!,
            detail: detail,
            messages: messages,
            status: status,
            title: title
        )
    }

}
