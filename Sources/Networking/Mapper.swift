//
//  Mapper.swift
//  Ello
//
//  Created by Sean on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct Mapper {

    public static func mapJSON(data: NSData) -> (AnyObject?, NSError?) {

        var error: NSError?
        var json: AnyObject?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch let error1 as NSError {
            error = error1
            json = nil
        }

        if json == nil && error != nil {
            let userInfo: [NSObject : AnyObject]? = ["data": data]
            error = NSError(domain: ElloErrorDomain, code: ElloErrorCode.JSONMapping.rawValue, userInfo: userInfo)
        }

        return (json, error)
    }

    public static func mapToObjectArray(object: AnyObject?, fromJSON: FromJSONClosure) -> [JSONAble]? {

        if let dicts = object as? [[String:AnyObject]] {
            let jsonables:[JSONAble] =  dicts.map {
                let jsonable = fromJSON(data: $0, fromLinked: false)
                return jsonable
            }
            return jsonables
        }

        return nil
    }

    public static func mapToObject(object:AnyObject?, fromJSON: FromJSONClosure) -> JSONAble? {
        if let dict = object as? [String:AnyObject] {
            let jsonable = fromJSON(data: dict, fromLinked: false)
            return jsonable
        }
        else {
            return nil
        }
    }
}
