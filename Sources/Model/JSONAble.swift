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
        var mutableData = data
        let links = data["links"] as [String:AnyObject]
        
        if let linked = linked {
            for (key, value) in links {
                if let link = value["type"] as? String {
                    if let mappedObjects = linked[link] {
                        for object:AnyObject in mappedObjects {
                            let objectId:String = object["id"] as String
                            let valueId:String = value["id"] as String
                            if objectId == valueId {
                                mutableData[key] = object
                            }
                        }
                    }
                }
            }
        }
        return mutableData
    }
}
