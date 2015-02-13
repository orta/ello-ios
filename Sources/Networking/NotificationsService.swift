//
//  NotificationsService.swift
//  Ello
//
//  Created by Colin Gray on 2/12/14.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

typealias NotificationsSuccessCompletion = (notifications: [Activity]) -> ()
typealias NotificationsFailureCompletion = (error: NSError, statusCode:Int?) -> ()

class NotificationsService: NSObject {
    class func loadStream(endpoint: ElloAPI, success: NotificationsSuccessCompletion, failure: NotificationsFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.ActivitiesType,
            success: { data in
                if let activities:[Activity] = data as? [Activity] {
                    success(notifications: activities)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
