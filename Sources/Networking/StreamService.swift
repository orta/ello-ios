//
//  StreamService.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

typealias StreamSuccessCompletion = (activities: [Activity]) -> ()
typealias StreamFailureCompletion = (error: NSError, statusCode:Int?) -> ()

class StreamService: NSObject {

    func loadFriendStream(success: StreamSuccessCompletion, failure: StreamFailureCompletion?) {
        let endpoint: ElloAPI = .FriendStream
        ElloProvider.sharedProvider.elloRequest(endpoint, method: .GET, parameters: endpoint.defaultParameters, propertyName:MappingType.Prop.Activities, success: { (data) -> () in
            if let activities:[Activity] = data as? [Activity] {
                success(activities: activities)
            }
            else {
                ElloProvider.unCastableJSONAble(failure)
            }
        }, failure: failure)
    }
}
