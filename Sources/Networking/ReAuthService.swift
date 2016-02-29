//
//  CredentialsAuthService.swift
//  Ello
//
//  Created by Sean Dougherty on 11/30/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Moya

public class ReAuthService {

    public func reAuthenticateToken(success success: AuthSuccessCompletion, failure: ElloFailureCompletion, noNetwork: ElloEmptyCompletion) {
        let endpoint: ElloAPI
        let token = AuthToken()
        let prevToken = token.token
        let refreshToken = token.refreshToken
        if let refreshToken = refreshToken where token.isPasswordBased {
            log("prev token: \(prevToken), requesting new token with: \(refreshToken)")
            endpoint = .ReAuth(token: refreshToken)
        }
        else {
            endpoint = .AnonymousCredentials
        }

        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .Success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                let data = moyaResponse.data

                switch statusCode {
                case 200...299:
                    AuthToken.storeToken(data, isPasswordBased: true)
                    log("created re-auth token: \(AuthToken().token)")
                    success()
                default:
                    log("refreshToken: \(refreshToken), failed to receive new token")
                    let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
                    failure(error: elloError, statusCode: statusCode)
                }
            case .Failure:
                noNetwork()
            }
        }
    }

    public func reAuthenticateUserCreds(success success: AuthSuccessCompletion, failure: ElloFailureCompletion, noNetwork: ElloEmptyCompletion) {
        var token = AuthToken()
        if let email = token.username, password = token.password {
            let endpoint: ElloAPI = .Auth(email: email, password: password)
            ElloProvider.sharedProvider.request(endpoint) { (result) in
                switch result {
                case let .Success(moyaResponse):
                    let statusCode = moyaResponse.statusCode
                    let data = moyaResponse.data

                    switch statusCode {
                    case 200...299:
                        AuthToken.storeToken(data, isPasswordBased: true)
                        log("created re-login token: \(AuthToken().token)")
                        success()
                    default:
                        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
                        failure(error: elloError, statusCode: statusCode)
                    }
                case .Failure:
                    noNetwork()
                }
            }
        }
        else {
            ElloProvider.failedToSendRequest(failure)
        }
    }

}
