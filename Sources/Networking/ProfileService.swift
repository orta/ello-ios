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


struct ProfileService {

    func loadCurrentUser(success: ProfileSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(ElloAPI.Profile,
            method: .GET,
            parameters: ElloAPI.Profile.defaultParameters,
            mappingType:MappingType.UsersType,
            success: { (data) -> () in
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