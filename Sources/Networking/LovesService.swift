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

    public func lovePost(
        #postId: String,
        success: ElloEmptyCompletion,
        failure: ElloFailureCompletion?)
    {
        let endpoint = ElloAPI.CreateLove(postId: postId)
        ElloProvider.elloRequest(endpoint,
            method: .POST,
            success: { _, _ in
                success()
            },
            failure: failure
        )
    }

    public func unlovePost(
        #postId: String,
        success: ElloEmptyCompletion,
        failure: ElloFailureCompletion?)
    {
        let endpoint = ElloAPI.DeleteLove(postId: postId)
        ElloProvider.elloRequest(endpoint,
            method: .DELETE,
            success: { _, _ in
                success()
            },
            failure: failure
        )
    }
}
