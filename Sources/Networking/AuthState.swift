//
//  AuthState.swift
//  Ello
//
//  Created by Colin Gray on 1/13/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public enum AuthState {
    case Initial  // auth is in indeterminate state

    case LoggedOut  // no auth or refresh token
    case Authenticated  // aww yeah - has token AND refreshToken

    case UserCredsSent  // creds have been sent
    case ShouldRetryUserCreds  // network is offline

    case RefreshTokenSent  // request is in flight
    case ShouldRetryRefreshToken  // network is offline

    var nextStates: [AuthState] {
        switch self {
        case Initial: return [.LoggedOut, .Authenticated]
        case LoggedOut: return [.UserCredsSent]
        case Authenticated: return [.RefreshTokenSent]

        case UserCredsSent: return [.LoggedOut, .Authenticated, .ShouldRetryUserCreds, .LoggedOut]
        case ShouldRetryUserCreds: return [.UserCredsSent]

        case RefreshTokenSent: return [.ShouldRetryRefreshToken, .UserCredsSent, .LoggedOut]
        case ShouldRetryRefreshToken: return [.RefreshTokenSent]
        }
    }
}
