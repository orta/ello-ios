//
//  ElloLinkedStore.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct ElloLinkedStore {

    public static var store = [String: [String: AnyObject]]()

    public static func parseLinked(linked:[String:[[String:AnyObject]]]){
        for (type:String, typeObjects: [[String:AnyObject]]) in linked {
            if store[type] == nil {
                store[type] = [String: JSONAble]()
            }
            for object:[String:AnyObject] in typeObjects {
                store[type]?[object["id"] as! String] = object
            }
//            for json: [String:AnyObject] in typeObjects {
//                if let mappingType = MappingType(rawValue: type) {
//                    let jsonable: JSONAble = mappingType.fromJSON(data: json)
//                    println("mappingType: \(mappingType.rawValue) jsonable: \(jsonable)")
//                    store[type]?[json["id"] as! String] = jsonable
//                }
//            }
        }
    }

    public static func parseLinks(links: [String: AnyObject]) -> [String: AnyObject] {
        var modelLinks = [String: AnyObject]()
        for (key, value) in links {
            if let link: String = value["type"] as? String {
                if let mappingType = MappingType(rawValue: value["type"] as! String) {
                    if let linkJSON = store[link]?[value["id"] as! String] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                    else if let model = store[link]?[value["id"] as! String] as? JSONAble {
                        modelLinks[key] = model
                    }
                }
            }
            else if let link: String = value as? String {
                if let mappingType = MappingType(rawValue: key) {
                    if let linkJSON = store[key]?[link] as? [String: AnyObject] {
                        var jsonable: JSONAble = mappingType.fromJSON(data: linkJSON)
                        modelLinks[key] = jsonable
                    }
                    else if let model = store[link]?[value["id"] as! String] as? JSONAble {
                        modelLinks[key] = model
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
        if let mappingType = MappingType(rawValue: key) {
            if mappingType.isOrdered {
                var linkArray = [JSONAble]()
                for str in strArray {
                    if let linkJSON = store[key]?[str] as? [String: AnyObject] {
                        let linkModel = mappingType.fromJSON(data: linkJSON)
                        linkArray.append(linkModel)
                    }
                    else if let linkModel = store[key]?[str] as? JSONAble {
                        linkArray.append(linkModel)
                    }
                }
                modelLinksCopy[key] = linkArray
            }
            else {
                var linkDict = [String: JSONAble]()
                for link: String in strArray {
                    if let linkJSON = store[key]?[link] as? [String: AnyObject] {
                        let linkModel = mappingType.fromJSON(data: linkJSON)
                        linkDict[link] = linkModel
                    }
                    else if let linkModel = store[key]?[link] as? JSONAble {
                        linkDict[link] = linkModel
                    }
                }
                modelLinksCopy[key] = linkDict
            }
        }
        return modelLinksCopy
    }
}
