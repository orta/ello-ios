//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class JSONAble: NSObject {

    var links = [String: AnyObject]()

    class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        return JSONAble()
    }

    class func parseLinks(links: [String: AnyObject], model: JSONAble) {
        for (key, value) in links {
            if let link:String = value["type"] as? String {
                if let mappingType = MappingType(rawValue: value["type"] as String) {
                    if let linkJSON = Store.store[link]?[value["id"] as String] as? [String: AnyObject] {
                        model.links[key] = mappingType.jsonableType.fromJSON(linkJSON)
                    }
                }
            }
            else if let strArray = links[key] as? [String] {
                if let mappingType = MappingType(rawValue: key) {
                    if mappingType.isOrdered {
                        var linkArray = [AnyObject]()
                        for str in strArray {
                            if let linkJSON = Store.store[key]?[str] as? [String: AnyObject] {
                                let linkModel = mappingType.jsonableType.fromJSON(linkJSON)
                                let user = model as? User
                                let post = linkModel  as? Post
                                if user != nil && post != nil {
                                    post!.author = user!
                                }
                                linkArray.append(linkModel)
                            }
                        }
                        model.links[key] = linkArray
                    }
                    else {
                        var linkDict = [String: AnyObject]()
                        for link: String in strArray {
                            if let linked: AnyObject = Store.store[key]?[link] {
                                linkDict[link] = linked
                            }
                        }
                        model.links[key] = linkDict
                    }
                }
            }
        }
    }
}
