//
//  RePostService.swift
//  Ello
//
//  Created by Colin Gray on 4/28/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class RePostService: NSObject {
    typealias RePostSuccessCompletion = (repost: Post) -> Void

    func repost(post post: Post, success: RePostSuccessCompletion, failure: ElloFailureCompletion) {
        let endpoint = ElloAPI.RePost(postId: post.id)
        ElloProvider.shared.elloRequest(endpoint,
            success: { data, responseConfig in
                if let repost = data as? Post {
                    success(repost: repost)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
