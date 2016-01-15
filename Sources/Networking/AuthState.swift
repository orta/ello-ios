//
//  AuthState.swift
//  Ello
//
//  Created by Colin Gray on 1/13/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public enum AuthState {
    public static var uuid: NSUUID = NSUUID()

    case Initial  // auth is in indeterminate state

    case LoggedOut  // no auth or refresh token
    case Authenticated  // aww yeah - has token AND refreshToken

    case UserCredsSent  // creds have been sent
    case ShouldTryUserCreds  // network is offline

    case RefreshTokenSent  // request is in flight
    case ShouldTryRefreshToken  // network is offline

    var nextStates: [AuthState] {
        switch self {
        case Initial: return [.LoggedOut, .Authenticated]
        case LoggedOut: return [.UserCredsSent]
        case Authenticated: return [.RefreshTokenSent]

        case RefreshTokenSent: return [.Authenticated, .ShouldTryRefreshToken, .ShouldTryUserCreds]
        case ShouldTryRefreshToken: return [.RefreshTokenSent]

        case UserCredsSent: return [.LoggedOut, .Authenticated, .ShouldTryUserCreds]
        case ShouldTryUserCreds: return [.UserCredsSent]
        }
    }

    var isAuthenticated: Bool {
        switch self {
        case Authenticated: return true
        default: return false
        }
    }

    var isLoggedOut: Bool {
        switch self {
        case LoggedOut: return true
        default: return false
        }
    }

    var isAuthenticating: Bool {
        switch self {
        case UserCredsSent, ShouldTryUserCreds,
             RefreshTokenSent, ShouldTryRefreshToken:
            return true
        default:
            return false
        }
    }

}
