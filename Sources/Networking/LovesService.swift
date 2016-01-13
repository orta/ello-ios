//
//  LovesService.swift
//  Ello
//
//  Created by Sean on 5/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias LovesCreateSuccessCompletion = (love: Love, responseConfig: ResponseConfig) -> Void

public struct LovesService {

    public init(){}

    public func lovePost(
        postId postId: String,
        success: LovesCreateSuccessCompletion,
        failure: ElloFailureCompletion)
    {
        let endpoint = ElloAPI.CreateLove(postId: postId)
        ElloProvider.shared.elloRequest(endpoint,
            success: { (data, responseConfig) in
                if let love = data as? Love {
                    success(love: love, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func unlovePost(
        postId postId: String,
        success: ElloEmptyCompletion,
        failure: ElloFailureCompletion)
    {
        let endpoint = ElloAPI.DeleteLove(postId: postId)
        ElloProvider.shared.elloRequest(endpoint,
            success: { _, _ in
                success()
            },
            failure: failure
        )
    }
}
