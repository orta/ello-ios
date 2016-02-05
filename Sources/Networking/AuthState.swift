//
//  AuthState.swift
//  Ello
//
//  Created by Colin Gray on 1/13/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import Foundation

public enum AuthState {
    public static var uuid: NSUUID = NSUUID()

    case Initial  // auth is in indeterminate state

    case NoToken  // no auth or refresh token
    case Anonymous  // anonymous token present
    case Authenticated  // aww yeah - has token AND refreshToken

    case UserCredsSent  // creds have been sent
    case ShouldTryUserCreds  // network is offline

    case RefreshTokenSent  // request is in flight
    case ShouldTryRefreshToken  // network is offline

    case AnonymousCredsSent
    case ShouldTryAnonymousCreds

    private var nextStates: [AuthState] {
        switch self {
        case Initial: return [.NoToken, .Anonymous, .Authenticated]

        case NoToken: return [.UserCredsSent, .AnonymousCredsSent, .ShouldTryAnonymousCreds]
        case Anonymous: return [.UserCredsSent, .NoToken]
        case Authenticated: return [.RefreshTokenSent, .NoToken]

        case RefreshTokenSent: return [.Authenticated, .ShouldTryRefreshToken, .ShouldTryUserCreds]
        case ShouldTryRefreshToken: return [.RefreshTokenSent]

        case UserCredsSent: return [.NoToken, .Authenticated, .ShouldTryUserCreds]
        case ShouldTryUserCreds: return [.UserCredsSent]

        case AnonymousCredsSent: return [.NoToken, .Anonymous]
        case ShouldTryAnonymousCreds: return [.AnonymousCredsSent]
        }
    }

    var isAuthenticated: Bool {
        switch self {
        case Authenticated: return true
        default: return false
        }
    }

    var isUndetermined: Bool {
        switch self {
        case Initial, NoToken: return true
        default: return false
        }
    }

    var isTransitioning: Bool {
        switch self {
        case Authenticated, Anonymous: return false
        default: return true
        }
    }

    func canTransitionTo(state: AuthState) -> Bool {
        return nextStates.contains(state)
    }

    func supports(target: ElloAPI) -> Bool {
        if !target.requiresAnyToken {
            return true
        }

        if isTransitioning {
            return false
        }

        if isAuthenticated {
            return true
        }

        return target.supportsAnonymousToken && self == .Anonymous
    }

}
