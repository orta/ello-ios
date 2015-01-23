//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class JSONAble: NSObject {
    class func fromJSON(data:[String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
        return JSONAble()
    }
    
    class func linkItems(data: [String: AnyObject], linked: [String:[AnyObject]]?) -> [String: AnyObject] {
        var linkedData = data
        let links = data["links"] as? [String:AnyObject]
       
        if links == nil {
            return data
        }
        
        // if linked is not nil
        if let linked = linked {
            // loop over objects in links
            for (key, value) in links! {
                // grab the type in links
                if let link:String = value["type"] as? String {
                    // grab the linked ojbect matching type

//                    if let mappedObjects = linked[link] as? [String:[AnyObject]] {
//                        let object = mappedObjects["id"] as AnyObject
//                        linkedData[key] = mappedObjects["id"] as AnyObject

//                        linkedData[key] =
//                        for object:AnyObject in mappedObjects {
//                            let objectId:String = object["id"] as String
//                            let valueId:String = value["id"] as String
//                            if objectId == valueId {
//                                linkedData[key] = object
//                            }
//                        }
//                    }
                }
            }
        }
        return linkedData
    }
}
