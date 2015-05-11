//
//  LovesService.swift
//  Ello
//
//  Created by Sean on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias LovesSuccessCompletion = (posts: [Post], responseConfig: ResponseConfig) -> () 

public struct LovesService {

    public init(){}

    public func loadLovesForUser(
        userId: String,
        streamKind: StreamKind?,
        success: LovesSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        ElloProvider.elloRequest(
            ElloAPI.Loves(userId: userId),
            method: .GET,
            success: { (data, responseConfig) in
                if let posts = data as? [Post] {
                    if let streamKind = streamKind {
                        Preloader().preloadImages(posts,  streamKind: streamKind)
                    }
                    success(posts: posts, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}

