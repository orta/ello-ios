//
//  NotificationsService.swift
//  Ello
//
//  Created by Colin Gray on 2/12/14.
//  Copyright (c) 2015 Ello. All rights reserved.
//

typealias NotificationsSuccessCompletion = (notifications: [Activity]) -> ()


class NotificationsService: NSObject {
    func load(# success: NotificationsSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = StreamKind.Notifications.endpoint
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
