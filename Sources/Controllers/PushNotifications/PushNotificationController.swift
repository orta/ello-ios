//
//  PushNotificationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class PushNotificationController {
    public static let sharedController = PushNotificationController()

    public init() {
        registerForLocalNotifications()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

public extension PushNotificationController {
    func registerForRemoteNotifications() {
        if !AuthToken().isAuthenticated { return }

        registerStoredToken()

        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: .None)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func updateToken(token: NSData) {
        Keychain.pushToken = token
        ProfileService().updateUserDeviceToken(token)
    }

    func registerStoredToken() {
        if let token = Keychain.pushToken {
            ProfileService().updateUserDeviceToken(token)
        }
    }

    @objc func deregisterStoredToken() {
        if let token = Keychain.pushToken {
            ProfileService().removeUserDeviceToken(token)
        }
    }
}

private extension PushNotificationController {
    func registerForLocalNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deregisterStoredToken"), name: Notifications.UserLoggedOut.rawValue, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deregisterStoredToken"), name: Notifications.SystemLoggedOut.rawValue, object: .None)
    }
}