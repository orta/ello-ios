//
//  InviteControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class InviteCacheSpec: QuickSpec {
    override func spec() {
        describe("saveInvite") {
            it("saves the contact id to the cache") {
                let inviteCache = InviteCache()
                let layer = FakePersistentLayer()
                inviteCache.cache.persistentLayer = layer
                inviteCache.saveInvite("contact id")
                expect(layer.object?.first) == "contact id"
            }
        }

        describe("has") {
            context("contact has been saved") {
                it("returns true") {
                    let inviteCache = InviteCache()
                    let layer = FakePersistentLayer()
                    layer.object = ["something", "else"]
                    inviteCache.cache.persistentLayer = layer
                    inviteCache.cache.load()
                    expect(inviteCache.has("else")).to(beTrue())
                }
            }

            context("contact has not been saved") {
                it("returns false") {
                    let inviteCache = InviteCache()
                    let layer = FakePersistentLayer()
                    layer.object = ["something", "else"]
                    inviteCache.cache.persistentLayer = layer
                    inviteCache.cache.load()
                    expect(inviteCache.has("something else")).to(beFalse())
                }
            }
        }
    }
}
