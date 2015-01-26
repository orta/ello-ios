//
//  JSONAble.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

//typealias ElloLinked = [String:[String:AnyObject]]?

class JSONAble: NSObject {
    class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        return JSONAble()
    }
    
    class func linkItems(data: [String: AnyObject]) -> [String: AnyObject] {
        var linkedData = data
        let links = data["links"] as? [String:AnyObject]
       
        if links == nil {
            return data
        }
        
        // loop over objects in links
        for (key, value) in links! {
            // grab the type in links
            if let link:String = value["type"] as? String {
                linkedData[key] = LinkedStore[link]?[value["id"] as String]?
            }
        }
        return linkedData
    }
}
