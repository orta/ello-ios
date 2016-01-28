//
//  CredentialsAuthService.swift
//  Ello
//
//  Created by Sean Dougherty on 11/30/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Moya

public typealias AuthSuccessCompletion = () -> Void

public class CredentialsAuthService {

    public func authenticate(email email: String, password: String, success: AuthSuccessCompletion, failure: ElloFailureCompletion) {
        let endpoint: ElloAPI = .Auth(email: email, password: password)
        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .Success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    ElloProvider.shared.authenticated(isPasswordBased: true)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: true, email: email, password: password)
                    log("created new token: \(AuthToken().token)")
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(moyaResponse.data, statusCode: moyaResponse.statusCode)
                    failure(error: elloError, statusCode: moyaResponse.statusCode)
                }
            case let .Failure(error):
                failure(error: error as NSError, statusCode: nil)
            }
        }
    }

}
