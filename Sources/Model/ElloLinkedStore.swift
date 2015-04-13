//
//  ElloLinkedStore.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public var Store = ElloLinkedStore()

public struct ElloLinkedStore {

    public var store = [String:[String:AnyObject]]()

    public mutating func parseLinked(linked:[String:[[String:AnyObject]]]){
        for (type:String, typeObjects:[[String:AnyObject]]) in linked {
            if store[type] == nil {
                store[type] = [String:AnyObject]()
            }
            for object:[String:AnyObject] in typeObjects {
                store[type]?[object["id"] as! String] = object
            }
        }
    }

    public static func parseLinks(links: [String: AnyObject]) -> [String: AnyObject] {
        var modelLinks = [String: AnyObject]()
        for (key, value) in links {
            if let link:String = value["type"] as? String {
                if let mappingType = MappingType.fromRawValue(value["type"] as! String) {
                    if let linkJSON = Store.store[link]?[value["id"] as! String] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                }
            }
            else if let link:String = value as? String {
                if let mappingType = MappingType.fromRawValue(key) {
                    if let linkJSON = Store.store[key]?[link] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                }
            }
            else if let strArray = links[key] as? [String] {
                modelLinks = parseArray(key, strArray: strArray, modelLinks: modelLinks)
            }
            else if let strArray = links[key]?["ids"] as? [String] {
                modelLinks = parseArray(key, strArray: strArray, modelLinks: modelLinks)
            }
        }
        return modelLinks
    }

    private static func parseArray(key: String, strArray: [String], modelLinks: [String: AnyObject]) -> [String: AnyObject] {
        var modelLinksCopy = modelLinks
        if let mappingType = MappingType.fromRawValue(key) {
            if mappingType.isOrdered {
                var linkArray = [JSONAble]()
                for str in strArray {
                    if let linkJSON = Store.store[key]?[str] as? [String: AnyObject] {
                        let linkModel = mappingType.fromJSON(data: linkJSON)
                        linkArray.append(linkModel)
                    }
                }
                modelLinksCopy[key] = linkArray
            }
            else {
                var linkDict = [String: JSONAble]()
                for link: String in strArray {
                    if let linkJSON = Store.store[key]?[link] as? [String: AnyObject] {
                        let linkModel = mappingType.fromJSON(data: linkJSON)
                        linkDict[link] = linkModel
                    }
                }
                modelLinksCopy[key] = linkDict
            }
        }
        return modelLinksCopy
    }
}
