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

    public func updateRelationship(userId userId: String, relationshipPriority: RelationshipPriority, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.Relationship(userId: userId, relationship: relationshipPriority.rawValue)
        ElloProvider.elloRequest(endpoint, success: { (data, responseConfig) in
            Tracker.sharedTracker.relationshipStatusUpdated(relationshipPriority, userId: userId)
            success(data: data, responseConfig: responseConfig)
        }, failure: { (error, statusCode) in
            Tracker.sharedTracker.relationshipStatusUpdateFailed(relationshipPriority, userId: userId)
            failure?(error: error, statusCode: statusCode)
        })
    }

    public func bulkUpdateRelationships(userIds userIds: [String], relationshipPriority: RelationshipPriority, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.RelationshipBatch(userIds: userIds, relationship: relationshipPriority.rawValue)
        ElloProvider.elloRequest(endpoint,
            success: success,
            failure: failure
        )
    }
}
