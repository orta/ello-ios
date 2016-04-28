//
//  ElloKeychain.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import KeychainAccess

public protocol KeychainType {
    var pushToken: NSData? { get set }
    var authToken: String? { get set }
    var refreshAuthToken: String? { get set }
    var authTokenType: String? { get set }
    var isPasswordBased: Bool? { get set }
    var username: String? { get set }
    var password: String? { get set }
}

private let PushToken = "ElloPushToken"
private let AuthTokenKey = "ElloAuthToken"
private let AuthTokenRefresh = "ElloAuthTokenRefresh"
private let AuthTokenType = "ElloAuthTokenType"
private let AuthTokenAuthenticated = "ElloAuthTokenAuthenticated"
private let AuthUsername = "ElloAuthUsername"
private let AuthPassword = "ElloAuthPassword"

public struct ElloKeychain: KeychainType {

    public init() {}
    public var keychain: Keychain {
        get {
            let appIdentifierPrefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AppIdentifierPrefix") as? String ?? "3D5U9ESH74"
            return Keychain(service: "co.ello.Ello", accessGroup: "\(appIdentifierPrefix).co.ello.Ello")
        }
    }

    public var pushToken: NSData? {
        get {
            if let pushToken = try? keychain.getData(PushToken) {
                return pushToken
            }
            return nil
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.set(newValue, key: PushToken)
                }
            }
            catch { }
        }
    }

    public var authToken: String? {
        get {
            if let authToken = try? keychain.get(AuthTokenKey) {
                return authToken
            }
            return nil
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.set(newValue, key: AuthTokenKey)
                }
            }
            catch {
                print("Unable to save auth token")
            }
        }
    }

    public var refreshAuthToken: String? {
        get {
            if let refreshAuthToken = try? keychain.get(AuthTokenRefresh) {
                return refreshAuthToken
            }
            return nil
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.updateIfNeeded(newValue, key: AuthTokenRefresh)
                }
            }
            catch {
                print("Unable to save refresh auth token")
            }
        }
    }


    public var authTokenType: String? {
        get {
            do { return try keychain.get(AuthTokenType) }
            catch { return nil }
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.updateIfNeeded(newValue, key: AuthTokenType)
                }
            }
            catch {
                print("Unable to save auth token type")
            }
        }
    }


    public var isPasswordBased: Bool? {
        get {
            do {
                let data = try keychain.getData(AuthTokenAuthenticated)
                if let data = data,
                    let number = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSNumber
                {
                    return number.boolValue
                }
                return nil
            }
            catch { return nil }
        }
        set {
            do {
                if let newValue = newValue {
                    let boolAsNumber = NSNumber(bool: newValue)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(boolAsNumber)
                    try keychain.set(data, key: AuthTokenAuthenticated)
                }
            }
            catch {
                print("Unable to save is password based")
            }
        }
    }

    public var username: String? {
        get {
            do { return try keychain.getString(AuthUsername) }
            catch { return nil }
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.updateIfNeeded(newValue, key: AuthUsername)
                }
            }
            catch {
                print("Unable to save username")
            }
        }
    }

    public var password: String? {
        get {
            do { return try keychain.getString(AuthPassword) }
            catch { return nil }
        }
        set {
            do {
                if let newValue = newValue {
                    try keychain.updateIfNeeded(newValue, key: AuthPassword)
                }
            }
            catch {
                print("Unable to save password")
            }
        }
    }
}

extension Keychain {

    public func updateIfNeeded(value: String, key: String) throws {
        if self[key] != value {
            try self.set(value, key: key)
        }
    }
}
