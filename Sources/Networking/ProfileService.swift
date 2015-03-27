//
//  ProfileService.swift
//  Ello
//
//  Created by Sean on 2/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import UIKit
import Moya
import SwiftyJSON

typealias ProfileFollowingSuccessCompletion = (users: [User], responseConfig: ResponseConfig) -> ()

struct ProfileService {

    func loadCurrentUser(success: ProfileSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(ElloAPI.Profile,
            method: .GET,
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

    func loadCurrentUserFollowing(forRelationship relationship: Relationship, success: ProfileFollowingSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(ElloAPI.ProfileFollowing(priority: relationship.rawValue),
            method: .GET,
            success: { data, responseConfig in
                if let users = data as? [User] {
                    success(users: users, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

}