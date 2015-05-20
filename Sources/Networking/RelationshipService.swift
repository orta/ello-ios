//
//  RelationshipService.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Moya
import SwiftyJSON

public class RelationshipService: NSObject {

    public func updateRelationship(endpoint:ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(endpoint,
            method: .POST,
            success: success,
            failure: failure
        )
    }

    public func bulkUpdateRelationships(#userIds: [String], relationship: RelationshipPriority, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.RelationshipBatch(userIds: userIds, relationship: relationship.rawValue)
        ElloProvider.elloRequest(endpoint,
            method: .POST,
            success: success,
            failure: failure
        )
    }

}
