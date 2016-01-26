//
//  AnonymousAuthService.swift
//  Ello
//
//  Created by Colin Gray on 1/25/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import Moya

public class AnonymousAuthService {

    public func authenticateAnonymously(success success: AuthSuccessCompletion, failure: ElloFailureCompletion, noNetwork: ElloEmptyCompletion) {
        let endpoint: ElloAPI = .AnonymousCredentials
        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .Success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    ElloProvider.shared.authenticated(isPasswordBased: false)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: false)
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
