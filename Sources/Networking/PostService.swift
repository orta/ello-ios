//
//  PostService.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias PostSuccessCompletion = (post: Post, responseConfig: ResponseConfig) -> Void
public typealias DeletePostSuccessCompletion = () -> Void

public struct PostService {

    public init(){}

    public func loadPost(
        postParam: String,
        streamKind: StreamKind?,
        success: PostSuccessCompletion,
        failure: ElloFailureCompletion?)
    {
        ElloProvider.elloRequest(
            ElloAPI.PostDetail(postParam: postParam),
            method: .GET,
            success: { (data, responseConfig) in
                if let post = data as? Post {
                    if let streamKind = streamKind {
                        Preloader().preloadImages([post],  streamKind: streamKind)
                    }
                    success(post: post, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func deletePost(
        postId: String,
        success: ElloEmptyCompletion?,
        failure: ElloFailureCompletion?)
    {
        ElloProvider.elloRequest(ElloAPI.DeletePost(postId: postId),
            method: .DELETE,
            success: { (_, _) in
                success?()
            }, failure: failure
        )
    }

    public func deleteComment(postId: String, commentId: String, success: ElloEmptyCompletion?, failure: ElloFailureCompletion?) {
        ElloProvider.elloRequest(ElloAPI.DeleteComment(postId: postId, commentId: commentId),
            method: .DELETE,
            success: { (_, _) in
                success?()
            }, failure: failure
        )
    }
}
