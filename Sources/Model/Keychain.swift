//
//  Keychain.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import LUKeychainAccess

private let PushToken = "ElloPushToken"

struct Keychain {
    static var pushToken: NSData? {
        get { return LUKeychainAccess.standardKeychainAccess().dataForKey(PushToken) as NSData? }
        set { LUKeychainAccess.standardKeychainAccess().setData(newValue, forKey: PushToken) }
    }
}
