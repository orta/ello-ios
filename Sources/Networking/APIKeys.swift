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

    public init() {
        let key : String = "f7e017"+"2b55a015e7b"+"dff49fcc9ca9df5050c79914897ba9f16b44e1b6f0099ac"
        let secret : String = "df89f7ca6c87"+"3bcf0ee62ae87321ce76"+"62163c71afea0fc51635c9fbacf76abb"
        self.init(key: key, secret: secret)
    }
}

