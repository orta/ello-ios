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
    
    class func linkItems(data: [String: AnyObject]) -> [String: AnyObject] {
        var linkedData = data
        let links = data["links"] as? [String: AnyObject]
       
        if links == nil {
            return data
        }

        // loop over objects in links
        for (key, value) in links! {
            // grab the type in links
            if let link:String = value["type"] as? String {
                linkedData[key] = Store.store[link]?[value["id"] as String]?
            }
                // should we create a dict or array from the links colleciton prop
            else if let links = value as? [String] {
                if let mappingType = MappingType(rawValue: key) {
                    if mappingType.isOrdered {
                        println("create array for: \(key)")
                        var linkArr = [AnyObject]()
                        for link:String in links {
                            if let linked: AnyObject = Store.store[key]?[link] {
                                linkArr.append(linked)
                            }
                        }
                        linkedData[key] = linkArr
                    } else {
                        println("create dict for: \(key)")
                        var linkDict = [String: AnyObject]()
                        for link:String in links {
                            if let linked: AnyObject = Store.store[key]?[link] {
                                linkDict[link] = linked
                            }
                        }
                        linkedData[key] = linkDict
                    }
                }
            }
        }
        return linkedData
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
                                let linkedModel = mappingType.jsonableType.fromJSON(linkJSON)
                                let user = model as? User
                                let post = linkedModel as? Post
                                if user != nil && post != nil {
                                    post!.author = user!
                                }
                                linkArray.append(linkedModel)
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
