//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import YapDatabase
import Foundation

public typealias FromJSONClosure = (data: [String: AnyObject], fromLinked: Bool) -> JSONAble

let JSONAbleVersion = 1

@objc(JSONAble)
public class JSONAble: NSObject, NSCoding {
    // links
    public var links: [String: AnyObject]?
    public let version: Int

    public init(version: Int) {
        self.version = version
        super.init()
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.links = decoder.decodeOptionalKey("links")
        self.version = decoder.decodeKey("version")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(links, forKey: "links")
        coder.encodeObject(version, forKey: "version")
    }

    public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return JSONAble(version: JSONAbleVersion)
    }

    public func merge(other: JSONAble) -> JSONAble {
        return other
    }
}

// MARK: Links methods to get JSONAbles

extension JSONAble {
    public func getLinkObject(identifier: String) -> JSONAble? {
        var obj: JSONAble?
        if let key = links?[identifier]?["id"] as? String, let collection = links?[identifier]?["type"] as? String {
            ElloLinkedStore.sharedInstance.database.newConnection().readWithBlock { transaction in
                obj = transaction.objectForKey(key, inCollection: collection) as? JSONAble
            }
        }
        else if let key = links?[identifier] as? String {
            ElloLinkedStore.sharedInstance.database.newConnection().readWithBlock { transaction in
                obj = transaction.objectForKey(key, inCollection: identifier) as? JSONAble
            }
        }
        return obj
    }

    public func getLinkArray(identifier: String) -> [JSONAble] {
        var arr = [JSONAble]()
        let ids: [String]? = self.links?[identifier] as? [String] ?? self.links?[identifier]?["ids"] as? [String]
        if let ids = ids {
            ElloLinkedStore.sharedInstance.database.newConnection().readWithBlock { transaction in
                for key in ids {
                    if let jsonable = transaction.objectForKey(key, inCollection: identifier) as? JSONAble {
                        arr += [jsonable]
                    }
                }
            }
        }
        return arr
    }

    public func addLinkObject(identifier: String, key: String, collection: String) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = ["id": key, "type": collection]

    }

    public func addLinkObject(model: JSONAble, identifier: String, key: String, collection: String) {
        if model.links == nil { links = [String: AnyObject]() }
        model.links![identifier] = ["id": key, "type": collection]
        ElloLinkedStore.sharedInstance.setObject(model, forKey: key, inCollection: collection)
    }

    public func clearLinkObject(identifier: String) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = nil
    }

    public func addLinkArray(identifier: String, array: [String]) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = array
    }
}
