//
//  ObjectCache.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

protocol PersistentLayer {
    func setObject(value: AnyObject?, forKey: String)
    func objectForKey(defaultName: String) -> AnyObject?
}

extension NSUserDefaults: PersistentLayer { }

class ObjectCache<T: AnyObject> {
    private let persistentLayer: PersistentLayer
    var cache: [T] = []
    let name: String

    init(name: String) {
        self.name = name
        persistentLayer = NSUserDefaults.standardUserDefaults()
    }

    init(name: String, persistentLayer: PersistentLayer) {
        self.name = name
        self.persistentLayer = persistentLayer
    }

    func append(item: T) {
        cache.append(item)
        persist()
    }

    func getAll() -> [T] {
        return cache
    }

    func persist() {
        persistentLayer.setObject(cache, forKey: name)
    }

    func load() {
        cache = persistentLayer.objectForKey(name) as? [T] ?? []
    }
}
