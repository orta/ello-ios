//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebLinking

typealias FromJSONClosure = (data: [String:AnyObject]) -> JSONAble

protocol URLResponsable: NSObjectProtocol {
//    var headers: [NSObject: AnyObject] { get }
    func parseResponse(response: NSURLResponse?)
}

class JSONAble : NSObject {
    class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        return JSONAble()
    }
}

extension JSONAble: URLResponsable {

    func parseResponse(response: NSURLResponse?) {
        if let response = response as? NSHTTPURLResponse {
            if let nextLink = response.findLink(relation: "next") {
                if let nextURL = NSURL(string: nextLink.uri as String) {
                    println("We have a next link with the URI: \(nextURL.query).")
                }
            }
            if let prevLink = response.findLink(relation: "prev") {
                if let prevURL = NSURL(string: prevLink.uri as String) {
                    println("We have a prev link with the URI: \(prevURL.query).")
                }
            }
        }
    }
}
