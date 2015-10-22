//
//  Keychain.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import LUKeychainAccess

public protocol KeychainType {
    var pushToken: NSData? { get set }
    var authToken: String? { get set }
    var refreshAuthToken: String? { get set }
    var authTokenExpires: NSDate? { get set }
    var authTokenType: String? { get set }
    var isAuthenticated: Bool? { get set }
}

private let PushToken = "ElloPushToken"
private let AuthTokenKey = "ElloAuthToken"
private let AuthTokenRefresh = "ElloAuthTokenRefresh"
private let AuthTokenExpires = "ElloAuthTokenExpires"
private let AuthTokenType = "ElloAuthTokenType"
private let AuthTokenAuthenticated = "ElloAuthTokenAuthenticated"

struct Keychain: KeychainType {
    var pushToken: NSData? {
        get { return LUKeychainAccess.standardKeychainAccess().dataForKey(PushToken) as NSData? }
        set { LUKeychainAccess.standardKeychainAccess().setData(newValue, forKey: PushToken) }
    }

    var authToken: String? {
        get { return LUKeychainAccess.standardKeychainAccess().stringForKey(AuthTokenKey) as String? }
        set { LUKeychainAccess.standardKeychainAccess().setString(newValue, forKey: AuthTokenKey) }
    }

    var refreshAuthToken: String? {
        get { return LUKeychainAccess.standardKeychainAccess().stringForKey(AuthTokenRefresh) as String? }
        set { LUKeychainAccess.standardKeychainAccess().setString(newValue, forKey: AuthTokenRefresh) }
    }

    var authTokenExpires: NSDate? {
        get {
            if let data = LUKeychainAccess.standardKeychainAccess().dataForKey(AuthTokenExpires) as NSData? {
                let coder = NSKeyedUnarchiver(forReadingWithData: data)
                return NSDate(coder: coder)
            }
            return nil
        }
        set {
            if let date = newValue {
                let data = NSKeyedArchiver.archivedDataWithRootObject(date)
                LUKeychainAccess.standardKeychainAccess().setData(data, forKey: AuthTokenExpires)
            }
            else {
                LUKeychainAccess.standardKeychainAccess().setData(nil, forKey: AuthTokenExpires)
            }
        }
    }

    var authTokenType: String? {
        get { return LUKeychainAccess.standardKeychainAccess().stringForKey(AuthTokenType) as String? }
        set { LUKeychainAccess.standardKeychainAccess().setString(newValue, forKey: AuthTokenType) }
    }

    var isAuthenticated: Bool? {
        get { return LUKeychainAccess.standardKeychainAccess().boolForKey(AuthTokenAuthenticated) as Bool? }
        set { LUKeychainAccess.standardKeychainAccess().setBool(newValue ?? false, forKey: AuthTokenAuthenticated) }
    }
}
