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

    public var database: YapDatabase
    public var readConnection: YapDatabaseConnection
    private var writeConnection: YapDatabaseConnection

    public init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let baseDir: String  = (count(paths) > 0 ? paths.first : NSTemporaryDirectory()) as! String
        let databaseName = "ello.sqlite"
        let path = baseDir.stringByAppendingPathComponent(databaseName)

        database = YapDatabase(path: path)
        readConnection = database.newConnection()
        readConnection.objectCacheLimit = 500        
        writeConnection = database.newConnection()
    }

    public func parseLinked(linked:[String:[[String:AnyObject]]]) {
        writeConnection.asyncReadWriteWithBlock { transaction in
            for (type:String, typeObjects: [[String:AnyObject]]) in linked {
                if let mappingType = MappingType(rawValue: type) {
                    for object:[String:AnyObject] in typeObjects {
                        let jsonable = mappingType.fromJSON(data: object)
                        if let post = jsonable as? Post {
                            transaction.setObject(jsonable, forKey: post.id, inCollection: type)
                        }
                        else if let user = jsonable as? User {
                            transaction.setObject(jsonable, forKey: user.id, inCollection: type)
                        }
                    }
                }
            }
        }
    }

    // primarialy used for testing for now.. could be used for setting a model after it's fromJSON
    public func setObject(object: JSONAble, forKey key: String, inCollection collection: String ) {
        writeConnection.asyncReadWriteWithBlock { transaction in
            transaction.setObject(object, forKey: key, inCollection: collection)
        }
    }

//    public func parseLinks(links: [String: AnyObject], completion: ParseLinksClosure?) {
//        var modelLinks = [String: AnyObject]()
//        readConnection.asyncReadWithBlock { transaction in
//            for (key, value) in links {
//                if let link:String = value["type"] as? String {
//                    if let mappingType = MappingType(rawValue: value["type"] as! String) {
//                        if let linkJSON = transaction.objectForKey(value["id"] as! String, inCollection: link) as? [String: AnyObject] {
//                            var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
//                            modelLinks[key] = jsonable
//                        }
//                        else if let linkModel = transaction.objectForKey(value["id"] as! String, inCollection: link) as? JSONAble {
//                            modelLinks[key] = linkModel
//                        }
//                    }
//                }
//                // for image regions
//                else if let link:String = value as? String {
//                    if let mappingType = MappingType(rawValue: key) {
//                        if let linkJSON = transaction.objectForKey(link, inCollection: key) as? [String: AnyObject] {
//                            var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
//                            modelLinks[key] = jsonable
//                        }
//                        else if let linkModel = transaction.objectForKey(link, inCollection: key) as? JSONAble {
//                            modelLinks[key] = linkModel
//                        }
//                    }
//                }
//                else if let strArray = links[key] as? [String] {
//                    modelLinks = self.parseArray(key, strArray: strArray, modelLinks: modelLinks, transaction: transaction)
//                }
//                else if let strArray = links[key]?["ids"] as? [String] {
//                    modelLinks = self.parseArray(key, strArray: strArray, modelLinks: modelLinks, transaction: transaction)
//                }
//            }
//            completion?(modelLinks)
//        }
//    }
//
//    private func parseArray(key: String, strArray: [String], modelLinks: [String: AnyObject], transaction: YapDatabaseReadTransaction) -> [String: AnyObject] {
//        var modelLinksCopy = modelLinks
//        if let mappingType = MappingType(rawValue: key) {
//            if mappingType.isOrdered {
//                var linkArray = [JSONAble]()
//                for str in strArray {
//                    if let linkJSON = transaction.objectForKey(str, inCollection: key) as? [String: AnyObject] {
//                        let linkModel = mappingType.fromJSON(data: linkJSON)
//                        linkArray.append(linkModel)
//                    }
//                    else if let linkModel = transaction.objectForKey(str, inCollection: key) as? JSONAble {
//                        linkArray.append(linkModel)
//                    }
//                }
//                modelLinksCopy[key] = linkArray
//            }
//            else {
//                var linkDict = [String: JSONAble]()
//                for link: String in strArray {
//                    if let linkJSON = transaction.objectForKey(link, inCollection: key) as? [String: AnyObject] {
//                        let linkModel = mappingType.fromJSON(data: linkJSON)
//                        linkDict[link] = linkModel
//                    }
//                    else if let linkModel = transaction.objectForKey(link, inCollection: key) as? JSONAble {
//                        linkDict[link] = linkModel
//                    }
//                }
//                modelLinksCopy[key] = linkDict
//            }
//        }
//        return modelLinksCopy
//    }
}
