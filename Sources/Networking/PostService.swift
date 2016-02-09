//
//  PostService.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias PostSuccessCompletion = (post: Post, responseConfig: ResponseConfig) -> Void
public typealias CommentSuccessCompletion = (comment: ElloComment, responseConfig: ResponseConfig) -> Void
public typealias DeletePostSuccessCompletion = () -> Void

public struct PostService {

    public init(){}

    public func loadPost(
        postParam: String,
        success: PostSuccessCompletion,
        failure: ElloFailureCompletion? = nil)
    {
        ElloProvider.shared.elloRequest(
            ElloAPI.PostDetail(postParam: postParam),
            success: { (data, responseConfig) in
                if let post = data as? Post {
                    Preloader().preloadImages([post],  streamKind: .PostDetail(postParam: postParam))
                    success(post: post, responseConfig: responseConfig)
                }
                else if let failure = failure {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: { (error, statusCode) in
                failure?(error: error, statusCode: statusCode)
            }
        )
    }

    public func loadComment(
        postId: String,
        commentId: String,
        success: CommentSuccessCompletion,
        failure: ElloFailureCompletion? = nil)
    {
        ElloProvider.shared.elloRequest(
            ElloAPI.CommentDetail(postId: postId, commentId: commentId),
            success: { (data, responseConfig) in
                if let comment = data as? ElloComment {
                    comment.loadedFromPostId = postId
                    success(comment: comment, responseConfig: responseConfig)
                }
                else if let failure = failure {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: { (error, statusCode) in
                failure?(error: error, statusCode: statusCode)
            }
        )
    }

    public func deletePost(
        postId: String,
        success: ElloEmptyCompletion?,
        failure: ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(ElloAPI.DeletePost(postId: postId),
            success: { (_, _) in
                NSURLCache.sharedURLCache().removeAllCachedResponses()
                success?()
            }, failure: failure
        )
    }

    public func deleteComment(postId: String, commentId: String, success: ElloEmptyCompletion?, failure: ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.DeleteComment(postId: postId, commentId: commentId),
            success: { (_, _) in
                success?()
            }, failure: failure
        )
    }
}
