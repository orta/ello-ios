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

public typealias StreamSuccessCompletion = (jsonables: [JSONAble], responseConfig: ResponseConfig) -> ()
public typealias ProfileSuccessCompletion = (user: User, responseConfig: ResponseConfig) -> ()

public class StreamService: NSObject {

    var isStreamLoading = false

    public func loadStream(endpoint:ElloAPI, success: StreamSuccessCompletion, failure: ElloFailureCompletion?, noContent: ElloEmptyCompletion? = nil) {
        if self.isStreamLoading { return }
        self.isStreamLoading = true
        ElloProvider.elloRequest(endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let jsonables:[JSONAble] = data as? [JSONAble] {
                    success(jsonables: jsonables, responseConfig: responseConfig)
                }
                else {
                    if let noContent = noContent {
                        noContent()
                    }
                    else {
                        ElloProvider.unCastableJSONAble(failure)
                    }
                }
                self.isStreamLoading = false
            },
            failure: { (error, statusCode) in
                failure!(error: error, statusCode: statusCode)
                self.isStreamLoading = false
            }
        )
    }

    public func loadUser(endpoint: ElloAPI, success: ProfileSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let user = data as? User {
                    success(user: user, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func loadMoreCommentsForPost(postID:String, success: StreamSuccessCompletion, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(.PostComments(postId: postID),
            method: .GET,
            success: { (data, responseConfig) in
                if let comments:[JSONAble] = data as? [JSONAble] {
                    success(jsonables: comments, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
