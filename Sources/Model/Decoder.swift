//
//  Decoder.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct Decoder {
    let decoder: NSCoder

    init(_ decoder: NSCoder) {
        self.decoder = decoder
    }
}

extension Decoder {
    func decodeKey<T>(key: String) -> T {
        return decoder.decodeObjectForKey(key) as! T
    }

    func decodeKey(key: String) -> Bool {
        if decoder.containsValueForKey(key) {
            return decoder.decodeBoolForKey(key)
        } else {
            return false
        }
    }

    func decodeKey(key: String) -> Int {
        return Int(decoder.decodeIntForKey(key))
    }
}

extension Decoder {
    func decodeOptionalKey<T>(key: String) -> T? {
        if decoder.containsValueForKey(key) {
            return decoder.decodeObjectForKey(key) as? T
        } else {
            return .None
        }
    }

    func decodeOptionalKey(key: String) -> Bool? {
        if decoder.containsValueForKey(key) {
            return decoder.decodeBoolForKey(key)
        } else {
            return .None
        }
    }

    func decodeOptionalKey(key: String) -> Int? {
        if decoder.containsValueForKey(key) {
            return Int(decoder.decodeIntForKey(key))
        } else {
            return .None
        }
    }
}
