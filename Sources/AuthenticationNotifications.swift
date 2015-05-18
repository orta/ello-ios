//
//  Notifications.swift
//  Ello
//
//  Created by Sean Dougherty on 12/5/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation


public struct AuthenticationNotifications {
    static let userLoggedOut = TypedNotification<()>(name: "UserElloLoggedOutNotification")
    static let invalidToken = TypedNotification<()>(name:"ElloInvalidTokenNotification")
}
