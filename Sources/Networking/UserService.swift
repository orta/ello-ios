//
//  UserService.swift
//  Ello
//
//  Created by Sean on 4/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import UIKit
import Moya
import SwiftyJSON


public struct UserService {

    public init(){}

    public func join(
        #email: String,
        username: String,
        password: String,
        success: ProfileSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        return join(email: email, username: username, password: password, invitationCode: nil, success: success, failure: failure)
    }

    public func join(
        #email: String,
        username: String,
        password: String,
        invitationCode: String?,
        success: ProfileSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        ElloProvider.elloRequest(ElloAPI.Join(email: email, username: username, password: password, invitationCode: invitationCode),
            method: .POST,
            success: { (data, responseConfig) in
                if let user = data as? User {
                    success(user: user)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
 }
