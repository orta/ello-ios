//
//  PushNotificationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyUserDefaults

private let NeedsPermissionKey = "PushNotificationNeedsPermission"
private let DeniedPermissionKey = "PushNotificationDeniedPermission"

public class PushNotificationController {
    public static let sharedController = PushNotificationController(defaults: Defaults, keychain: Keychain())

    private let defaults: NSUserDefaults
    private var keychain: KeychainType

    private var userLoggedOutObserver: NotificationObserver?
    private var systemLoggedOutObserver: NotificationObserver?

    public var needsPermission: Bool {
        get { return defaults[NeedsPermissionKey].bool ?? true }
        set { defaults[NeedsPermissionKey] = newValue }
    }

    public var permissionDenied: Bool {
        get { return defaults[DeniedPermissionKey].bool ?? false }
        set { defaults[DeniedPermissionKey] = newValue }
    }

    public init(defaults: NSUserDefaults, keychain: KeychainType) {
        self.defaults = defaults
        self.keychain = keychain
        registerForLocalNotifications()
    }

    deinit {
        userLoggedOutObserver?.removeObserver()
        systemLoggedOutObserver?.removeObserver()
    }
}

public extension PushNotificationController {
    func requestPushAccessIfNeeded() -> AlertViewController? {
        if !AuthToken().isAuthenticated { return .None }
        if permissionDenied { return .None }

        if needsPermission { return alertViewController() }

        registerForRemoteNotifications()
        return .None
    }

    func registerForRemoteNotifications() {
        self.needsPermission = false
        registerStoredToken()

        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: .None)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func updateToken(token: NSData) {
        keychain.pushToken = token
        ProfileService().updateUserDeviceToken(token)
    }

    func registerStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().updateUserDeviceToken(token)
        }
    }

    @objc func deregisterStoredToken() {
        if let token = keychain.pushToken {
            ProfileService().removeUserDeviceToken(token)
        }
    }
}

private extension PushNotificationController {
    func registerForLocalNotifications() {
        userLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.userLoggedOut, block: deregisterStoredToken)
        systemLoggedOutObserver = NotificationObserver(notification: AuthenticationNotifications.systemLoggedOut, block: deregisterStoredToken)
    }

    func alertViewController() -> AlertViewController {
        let alert = AlertViewController(message: NSLocalizedString("Allow Push Notifications?", comment: "Turn on Push Notifications?"))
        alert.dismissable = false

        let disallowAction = AlertAction(title: NSLocalizedString("Disallow", comment: "Disallow"), style: .Dark) { _ in
            self.needsPermission = false
            self.permissionDenied = true
        }
        alert.addAction(disallowAction)

        let allowAction = AlertAction(title: NSLocalizedString("Allow", comment: "Allow"), style: .Light) { _ in
            self.registerForRemoteNotifications()
        }
        alert.addAction(allowAction)

        return alert
    }
}