//
//  ElloLinkedStore.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

var Store = ElloLinkedStore()

struct ElloLinkedStore {

    var store = [String:[String:AnyObject]]()

    mutating func parseLinked(linked:[String:[[String:AnyObject]]]){
        for (type:String, typeObjects:[[String:AnyObject]]) in linked {
            if store[type] == nil {
                store[type] = [String:AnyObject]()
            }
            for object:[String:AnyObject] in typeObjects {
                store[type]?[object["id"] as String] = object
            }
        }
    }

     static func parseLinks(links: [String: AnyObject]) -> [String: AnyObject] {
        var modelLinks = [String: AnyObject]()
        for (key, value) in links {
            if let link:String = value["type"] as? String {
                if let mappingType = MappingType(rawValue: value["type"] as String) {
                    if let linkJSON = Store.store[link]?[value["id"] as String] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                }
            }
            else if let link:String = value as? String {
                if let mappingType = MappingType(rawValue: key) {
                    if let linkJSON = Store.store[key]?[link] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                }
            }
            else if let strArray = links[key] as? [String] {
                if let mappingType = MappingType(rawValue: key) {
                    if mappingType.isOrdered {
                        var linkArray = [JSONAble]()
                        for str in strArray {
                            if let linkJSON = Store.store[key]?[str] as? [String: AnyObject] {
                                let linkModel = mappingType.fromJSON(data: linkJSON)
//                                let user = model as? User
//                                let post = linkModel  as? Post
//                                if user != nil && post != nil {
//                                    post!.author = user!
//                                }
                                linkArray.append(linkModel)
                            }
                        }
                        modelLinks[key] = linkArray
                    }
                    else {
                        var linkDict = [String: JSONAble]()
                        for link: String in strArray {
                            if let linkJSON = Store.store[key]?[link] as? [String: AnyObject] {
                                let linkModel = mappingType.fromJSON(data: linkJSON)
                                linkDict[link] = linkModel
                            }
                        }
                        modelLinks[key] = linkDict
                    }
                }
            }
        }
        return modelLinks
    }

}