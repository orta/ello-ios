//
//  DictionaryExtensions.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as Value, forKey: k as Key)
        }
    }
}

func +<K, V> (left: [K:V], right: [K:V]) -> [K:V] {
    var d : [K:V] = [:]
    d.merge(left)
    d.merge(right)
    return d
}
