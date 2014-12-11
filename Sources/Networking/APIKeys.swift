//
//  APIKeys.swift
//  Ello
//
//  Created by Sean Dougherty on 11/26/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation
import Pods

// Mark: - API Keys

public struct APIKeys {
    let key: String
    let secret: String

    // MARK: Shared Keys

    private struct SharedKeys {
        static var instance = APIKeys()
    }

    public static var sharedKeys: APIKeys {
        get {
        return SharedKeys.instance
        }

        set (newSharedKeys) {
            SharedKeys.instance = newSharedKeys
        }
    }

    // MARK: Methods

    public var stubResponses: Bool {
        return countElements(key) == 0 || countElements(secret) == 0
    }

    // MARK: Initializers

    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }

//    public init(keys: ElloKeys) {
//        self.init(key: keys.elloAPIClientKey() ?? "", secret: keys.elloAPIClientSecret() ?? "")
//    }

    public init() {
//        let keys = ElloKeys()
        self.init(key: "e057fa8a53b1544ab0872485b5339c30d909957a54e8d15e89c75bb96fa0b6e8", secret: "071c12dfcd65db6d54b757267ff930cf1488262efb04aa38b870712c1a33bf05")
    }
}

