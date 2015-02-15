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

typealias StreamSuccessCompletion = (jsonables: [JSONAble]) -> ()
typealias PostSuccessCompletion = (post: Post) -> ()
typealias ProfileSuccessCompletion = (user: User) -> ()


class StreamService: NSObject {

    func loadStream(endpoint:ElloAPI, success: StreamSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.ActivitiesType,
            success: { (data) -> () in
                if let activities:[Activity] = data as? [Activity] {
                    success(jsonables: activities)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    func loadUser(endpoint: ElloAPI, success: ProfileSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.UsersType,
            success: { data in
                if let user = data as? User {
                    success(user: user)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    func loadMoreCommentsForPost(postID:String, success: StreamSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint: ElloAPI = .PostComments(postId: postID)
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType:MappingType.CommentsType,
            success: { data in
                if let comments:[JSONAble] = data as? [JSONAble] {
                    success(jsonables: comments)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
