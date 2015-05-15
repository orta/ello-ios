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
import SDWebImage

public typealias StreamSuccessCompletion = (jsonables: [JSONAble], responseConfig: ResponseConfig) -> ()
public typealias UserSuccessCompletion = (user: User, responseConfig: ResponseConfig) -> ()

public class StreamService: NSObject {

    public func loadStream(
        endpoint:ElloAPI,
        streamKind: StreamKind?,
        success: StreamSuccessCompletion,
        failure: ElloFailureCompletion?,
        noContent: ElloEmptyCompletion? = nil)
    {
        ElloProvider.elloRequest(
            endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let jsonables = data as? [JSONAble] {
                    if let streamKind = streamKind {
                        Preloader().preloadImages(jsonables,  streamKind: streamKind)
                    }
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
            },
            failure: { (error, statusCode) in
                failure!(error: error, statusCode: statusCode)
            }
        )
    }

    public func loadUser(
        endpoint: ElloAPI,
        streamKind: StreamKind?,
        success: UserSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        ElloProvider.elloRequest(
            endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let user = data as? User {
                    if let streamKind = streamKind {
                        Preloader().preloadImages([user], streamKind: streamKind)
                    }
                    success(user: user, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func loadMoreCommentsForPost(
        postId:String,
        streamKind: StreamKind?,
        success: StreamSuccessCompletion,
        failure: ElloFailureCompletion?,
        noContent: ElloEmptyCompletion? = nil)
    {
        ElloProvider.elloRequest(
            .PostComments(postId: postId),
            method: .GET,
            success: { (data, responseConfig) in
                if let comments:[Comment] = data as? [Comment] {
                    comments.map { $0.loadedFromPostId = postId }
                    if let streamKind = streamKind {
                        Preloader().preloadImages(comments, streamKind: streamKind)
                    }
                    success(jsonables: comments, responseConfig: responseConfig)
                }
                else if let noContent = noContent {
                    noContent()
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
