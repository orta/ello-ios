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
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)

        if json == nil && error != nil {
            var userInfo: [NSObject : AnyObject]? = ["data": data]
            error = NSError(domain: ElloErrorDomain, code: ElloErrorCode.JSONMapping.rawValue, userInfo: userInfo)
        }

        return (json, error)
    }

    public static func mapToObjectArray(object: AnyObject?, fromJSON: FromJSONClosure, linkObject: LinkObject?) -> [JSONAble]? {

        if let dicts = object as? [[String:AnyObject]] {
            let jsonables:[JSONAble] =  dicts.map {
                let jsonable = fromJSON(data: $0)
                if let linkObject = linkObject {
                    jsonable.addLinkObject(linkObject.identifier, key: linkObject.key, collection: linkObject.collection)
                }
                return jsonable
            }
            return jsonables
        }

        return nil
    }

    public static func mapToObject(object:AnyObject?, fromJSON: FromJSONClosure) -> JSONAble? {
        if let dict = object as? [String:AnyObject] {
            let jsonable = fromJSON(data: dict)
            return jsonable
        }
        else {
            return nil
        }
    }
}
