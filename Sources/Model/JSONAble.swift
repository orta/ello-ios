//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import YapDatabase

public typealias FromJSONClosure = (data: [String: AnyObject], fromLinked: Bool) -> JSONAble

public class JSONAble: NSObject, NSCoding {
    // links
    public var links: [String: AnyObject]?

    public override init() {
        super.init()
    }

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.links = decoder.decodeOptionalKey("links")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(links, forKey: "links")
    }

    public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        return JSONAble()
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
        var ids: [String]? = self.links?[identifier] as? [String] ?? self.links?[identifier]?["ids"] as? [String]
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

    public func addLinkArray(identifier: String, array: [String]) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = array
    }
}
