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

typealias PostSuccessCompletion = (post: Post) -> ()
typealias PostFailureCompletion = (error: NSError, statusCode:Int?) -> ()


typealias CommentsSuccessCompletion = (comments: [Comment]) -> ()
typealias CommentsFailureCompletion = (error: NSError, statusCode:Int?) -> ()

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
    
    func loadMoreCommentsForPost(postID:String, success: CommentsSuccessCompletion, failure: CommentsFailureCompletion?) {
        let endpoint: ElloAPI = .PostComments(postId: postID)
        ElloProvider.sharedProvider.elloRequest(endpoint, method: .GET, parameters: endpoint.defaultParameters, propertyName:MappingType.Prop.Comments, success: { (data) -> () in
            if let comments:[Comment] = data as? [Comment] {
                success(comments: comments)
            }
            else {
                ElloProvider.unCastableJSONAble(failure)
            }
        }, failure: failure)
    }
}
