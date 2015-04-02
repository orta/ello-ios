//
//  AvailabilityService.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/30/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Moya
import SwiftyJSON

typealias AvailabilitySuccessCompletion = (Availability) -> ()

struct AvailabilityService {
    func usernameAvailability(username: String, success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion?) {
        availability(["username": username], success: success, failure: failure)
    }

    func emailAvailability(email: String, success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion?) {
        availability(["email": email], success: success, failure: failure)
    }

    func availability(content: [String: String], success: AvailabilitySuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.Availability(content: content)
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .POST,
            success: { data, _ in
                if let data = data as? Availability {
                    success(data)
                } else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure)
    }
}


