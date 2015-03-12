//
//  InviteCache.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct InviteCache {
    var cache = ObjectCache<NSString>(name: "ElloInviteCache")

    init() {
        cache.load()
    }

    func saveInvite(contactID: String) {
        if has(contactID) { return }
        cache.append(contactID)
    }

    func has(contactID: String) -> Bool {
        println(cache.getAll())
        return contains(cache.getAll(), contactID)
    }
}
