//
//  FakePersistentLayer.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello


public class FakePersistentLayer: PersistentLayer {
    var object: [String]?

    init() { }

    public func setObject(value: AnyObject?, forKey: String) {
        object = value as? [String]
    }

    public func objectForKey(defaultName: String) -> AnyObject? {
        return object ?? []
    }
}
