//
//  InviteControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class ObjectCacheSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("sets the name of the cache") {
                let cache = ObjectCache<NSString>(name: "test")
                expect(cache.name) == "test"
            }

            it("sets NSUserDefaults as the default persistent layer") {
                let cache = ObjectCache<NSString>(name: "test")
                cache.append("hello")
                let defaults = NSUserDefaults(suiteName: "group.ello.Ello") ?? NSUserDefaults.standardUserDefaults()
                expect(defaults.objectForKey("test") as? [String]) == ["hello"]
            }
        }

        describe("append") {
            it("appends a value to the cache") {
                let layer = FakePersistentLayer()
                let cache = ObjectCache<NSString>(name: "test", persistentLayer: layer)
                cache.append("something")
                expect(cache.cache.first) == "something"
            }

            it("persists the value to the persistent layer") {
                let layer = FakePersistentLayer()
                let cache = ObjectCache<NSString>(name: "test", persistentLayer: layer)
                cache.append("something")
                expect(layer.object?.first) == "something"
            }
        }


        describe("getAll") {
            it("returns the cache") {
                let cache = ObjectCache<NSString>(name: "test")
                cache.cache = ["something", "else"]
                expect(cache.getAll()) == cache.cache
            }
        }

        describe("load") {
            it("loads the cache from the persistent layer") {
                let layer = FakePersistentLayer()
                layer.object = ["something", "else"]
                let cache = ObjectCache<NSString>(name: "test", persistentLayer: layer)
                cache.load()
                expect(cache.cache) == layer.object
            }
        }
    }
}
