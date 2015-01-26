//
//  ElloLinkedStore.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

var Store = ElloLinkedStore()

class ElloLinkedStore {

    var store = [String:[String:AnyObject]]()

    func parseLinked(linked:[String:[[String:AnyObject]]]){
        for (type:String, typeObjects:[[String:AnyObject]]) in linked {
            if store[type] == nil {
                store[type] = [String:AnyObject]()
            }
            for object:[String:AnyObject] in typeObjects {
                store[type]?[object["id"] as String] = object
            }
        }
    }
}