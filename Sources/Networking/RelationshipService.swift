//
//  RelationshipService.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class RelationshipService: NSObject {

    func updateRelationship(endpoint:ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .POST,
            parameters: endpoint.defaultParameters,
            mappingType: MappingType.RelationshipsType,
            success: success,
            failure: failure
        )
    }
}
