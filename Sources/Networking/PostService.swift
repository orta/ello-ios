//
//  PostService.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias PostSuccessCompletion = (post: Post, responseConfig: ResponseConfig) -> Void
public typealias UsernamesSuccessCompletion = (usernames: [String]) -> Void
public typealias CommentSuccessCompletion = (comment: ElloComment, responseConfig: ResponseConfig) -> Void
public typealias DeletePostSuccessCompletion = () -> Void

public struct PostService {

    public init(){}

    public func loadPost(
        postParam: String,
        needsComments: Bool,
        success: PostSuccessCompletion,
        failure: ElloFailureCompletion? = nil)
    {
        let commentCount = needsComments ? 10 : 0
        ElloProvider.shared.elloRequest(
            ElloAPI.PostDetail(postParam: postParam, commentCount: commentCount),
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

    public func loadReplyAll(
        postId: String,
        success: UsernamesSuccessCompletion,
        failure: ElloEmptyCompletion)
    {
        // ElloProvider.shared.elloRequest(ElloAPI.PostReplyAll(postId: postId),
        //     success: { (usernames, _) in
        //         if let usernames = usernames as? [Username] {
        //             success(usernames.map { $0.username })
        //         }
        //     }, failure: { _ in failure() }
        // )
        ElloProvider.sharedProvider.request(.PostReplyAll(postId: postId)) { (result) in
            switch result {
            case let .Success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                switch statusCode {
                case 200...299, 300...399:
                    let (mappedJSON, _): (AnyObject?, NSError?) = Mapper.mapJSON(data)
                    if let usernames = mappedJSON as? [String] {
                        success(usernames: usernames)
                    }
                default:
                    failure()
                }
            default:
                failure()
            }
        }
    }

    public func deletePost(
        postId: String,
        success: ElloEmptyCompletion?,
        failure: ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(ElloAPI.DeletePost(postId: postId),
            success: { (_, _) in
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
