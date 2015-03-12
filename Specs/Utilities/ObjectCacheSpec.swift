//
//  InviteControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class ObjectCacheSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("sets the name of the cache") {
                var layer = FakePersistentLayer()
                layer.object = ["something", "else"]
                var cache = ObjectCache<NSString>(name: "test")
                expect(cache.name) == "test"
            }

            it("sets NSUserDefaults as the default persistent layer") {
                var cache = ObjectCache<NSString>(name: "test")
                expect(cache.persistentLayer as? NSUserDefaults).to(beAKindOf(NSUserDefaults))
            }
        }

        describe("append") {
            it("appends a value to the cache") {
                var layer = FakePersistentLayer()
                var cache = ObjectCache<NSString>(name: "test")
                cache.persistentLayer = layer
                cache.append("something")
                expect(cache.cache.first) == "something"
            }

            it("persists the value to the persistent layer") {
                var layer = FakePersistentLayer()
                var cache = ObjectCache<NSString>(name: "test")
                cache.persistentLayer = layer
                cache.append("something")
                expect(layer.object?.first) == "something"
            }
        }

        describe("getAll") {
            it("returns the cache") {
                var cache = ObjectCache<NSString>(name: "test")
                cache.cache = ["something", "else"]
                expect(cache.getAll()) == cache.cache
            }
        }

        describe("load") {
            it("loads the cache from the persistent layer") {
                var layer = FakePersistentLayer()
                layer.object = ["something", "else"]
                var cache = ObjectCache<NSString>(name: "test")
                cache.persistentLayer = layer
                cache.load()
                expect(cache.cache) == layer.object
            }
        }
    }
}
