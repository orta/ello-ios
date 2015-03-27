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

    func invite(contact: String, success: InviteFriendsSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(ElloAPI.InviteFriends(contact: contact),
            method: .POST,
            success: { _ in success() },
            failure: failure)
    }

    func find(contacts:[String: AnyObject], success: FindFriendsSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(ElloAPI.FindFriends(contacts: contacts),
            method: .POST,
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