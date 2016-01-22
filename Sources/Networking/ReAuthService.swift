//
//  AuthService.swift
//  Ello
//
//  Created by Sean Dougherty on 11/30/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Moya
import SwiftyJSON

public class ReAuthService: NSObject {

    public func reAuthenticateToken(success success: AuthSuccessCompletion, failure: ElloFailureCompletion, noNetwork: ElloEmptyCompletion) {

        let endpoint: ElloAPI
        let token = AuthToken()
        let prevToken = token.token
        let refreshToken = token.refreshToken
        if let refreshToken = refreshToken where token.isPresent && token.isAuthenticated {
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
                    self.storeToken(data, endpoint: endpoint)
                    log("refreshToken: \(refreshToken), received new token: \(token.token)")
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
                        self.storeToken(data, endpoint: endpoint)
                        log("created new token: \(AuthToken().token)")
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

    private func storeToken(data: NSData, endpoint: ElloAPI) {
        var authToken = AuthToken()

        switch endpoint {
        case .AnonymousCredentials: authToken.isAuthenticated = false
        default: authToken.isAuthenticated = true
        }

        do {
            let json = try JSON(data: data)
            authToken.token = json["access_token"].stringValue
            authToken.type = json["token_type"].stringValue
            authToken.refreshToken = json["refresh_token"].stringValue
        }
        catch {
            log("failed to create JSON and store authToken")
        }
    }
}
