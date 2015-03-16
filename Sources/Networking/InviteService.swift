//
//  InviteService.swift
//  Ello
//
//  Created by Sean on 2/27/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

typealias InviteFriendsSuccessCompletion = () -> ()
typealias FindFriendsSuccessCompletion = ([User]) -> ()

struct InviteService {

    func invite(contacts:[String], success: InviteFriendsSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.InviteFriends(contacts: contacts)
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .POST,
            parameters: endpoint.defaultParameters,
            mappingType: MappingType.NoContentType,
            success: { data in
                success()
            }, failure: failure)
    }

    func find(contacts:[String: AnyObject], success: FindFriendsSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.FindFriends
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .POST,
            parameters: contacts,
            mappingType: MappingType.UsersType,
            success: { (data, responseConfig) -> () in
                if let data = data as? [User] {
                    success(data)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            }, failure: failure)
    }
    
}