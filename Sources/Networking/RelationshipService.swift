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

public class RelationshipService: NSObject {

    public func updateRelationship(endpoint:ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(endpoint,
            method: .POST,
            success: success,
            failure: failure
        )
    }
}
