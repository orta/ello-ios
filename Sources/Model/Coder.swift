//
//  Decoder.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public struct Coder {
    public let coder: NSCoder

    public init(_ coder: NSCoder) {
        self.coder = coder
    }
}

public extension Coder {
    func decodeKey<T>(key: String) -> T {
        return coder.decodeObjectForKey(key) as! T
    }

    func decodeKey(key: String) -> Bool {
        if coder.containsValueForKey(key) {
            return coder.decodeBoolForKey(key)
        } else {
            return false
        }
    }

    func decodeKey(key: String) -> Int {
        return Int(coder.decodeIntForKey(key))
    }
}

public extension Coder {
    func decodeOptionalKey<T>(key: String) -> T? {
        if coder.containsValueForKey(key) {
            return coder.decodeObjectForKey(key) as? T
        } else {
            return .None
        }
    }

    func decodeOptionalKey(key: String) -> Bool? {
        if coder.containsValueForKey(key) {
            return coder.decodeBoolForKey(key)
        } else {
            return .None
        }
    }

    func decodeOptionalKey(key: String) -> Int? {
        if coder.containsValueForKey(key) {
            return Int(coder.decodeIntForKey(key))
        } else {
            return .None
        }
    }
}

public extension Coder {
    func encodeObject(obj: Any?, forKey key: String) {
        if let bool = obj as? Bool {
            coder.encodeBool(bool, forKey: key)
        }
        else if let int = obj as? Int {
            coder.encodeInt64(Int64(int), forKey: key)
        }
        else if let obj: AnyObject = obj as? AnyObject {
            coder.encodeObject(obj, forKey: key)
        }
    }
}
