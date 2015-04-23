//
//  ElloLinkedStore.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import YapDatabase

private let _ElloLinkedStore = ElloLinkedStore()


public struct ElloLinkedStore {

    public static var sharedInstance: ElloLinkedStore { return _ElloLinkedStore }
    public static var databaseName = "ello.sqlite"

    public var database: YapDatabase
    public var readConnection: YapDatabaseConnection
    private var writeConnection: YapDatabaseConnection

    public init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let baseDir: String  = (count(paths) > 0 ? paths.first : NSTemporaryDirectory()) as! String
        let path = baseDir.stringByAppendingPathComponent(ElloLinkedStore.databaseName)

        database = YapDatabase(path: path)
        readConnection = database.newConnection()
        readConnection.objectCacheLimit = 500        
        writeConnection = database.newConnection()
    }

    public func parseLinked(linked:[String:[[String:AnyObject]]]) {
        writeConnection.readWriteWithBlock { transaction in
            for (type:String, typeObjects: [[String:AnyObject]]) in linked {
                if let mappingType = MappingType(rawValue: type) {
                    for object: [String:AnyObject] in typeObjects {
                        if let id = object["id"] as? String {
                            let jsonable = mappingType.fromJSON(data: object, fromLinked: true)
                            transaction.setObject(jsonable, forKey: id, inCollection: type)
                        }
                    }
                }
            }
        }
    }

    // primarialy used for testing for now.. could be used for setting a model after it's fromJSON
    public func setObject(object: JSONAble, forKey key: String, inCollection collection: String ) {
        writeConnection.readWriteWithBlock { transaction in
            transaction.setObject(object, forKey: key, inCollection: collection)
        }
    }

    public func getObject(key: String, inCollection collection: String) -> JSONAble? {
        var object: JSONAble?
        readConnection.readWithBlock { transaction in
            if transaction.hasObjectForKey(key, inCollection: collection) {
                object = transaction.objectForKey(key, inCollection: collection) as? JSONAble
            }
        }
        return object
    }
}
