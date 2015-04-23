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

    public func loadStream(endpoint:ElloAPI, streamKind: StreamKind?, success: StreamSuccessCompletion, failure: ElloFailureCompletion?, noContent: ElloEmptyCompletion? = nil) {
        ElloProvider.elloRequest(endpoint,
            method: .GET,
            success: { (data, responseConfig) in
                if let jsonables:[JSONAble] = data as? [JSONAble] {
                    if let streamKind = streamKind {
                        self.preloadImages(jsonables, streamKind: streamKind)
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

    public func loadUser(endpoint: ElloAPI, success: UserSuccessCompletion, failure: ElloFailureCompletion?) {
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

    public func loadMoreCommentsForPost(postID:String, success: StreamSuccessCompletion, failure: ElloFailureCompletion?, noContent: ElloEmptyCompletion? = nil) {
        ElloProvider.elloRequest(.PostComments(postId: postID),
            method: .GET,
            success: { (data, responseConfig) in
                if let comments:[JSONAble] = data as? [JSONAble] {
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

    private func preloadImages(jsonables: [JSONAble], streamKind: StreamKind) {

        // preload avatars
        for jsonable in jsonables {
            if let activity = jsonable as? Activity,
                let authorable = activity.subject as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL
            {
                let manager = SDWebImageManager.sharedManager()
                manager.downloadImageWithURL(avatarURL,
                    options: SDWebImageOptions.LowPriority,
                    progress: { (_, _) in }, completed: { (_, _, _, _, _) in})
            }
        }
        // preload images in image regions
        for jsonable in jsonables {
            if let activity = jsonable as? Activity,
                let post = activity.subject as? Post,
                let content = streamKind.isGridLayout ? post.summary: post.content
            {
                for region in content {
                    if let imageRegion = region as? ImageRegion,
                        let asset = imageRegion.asset,
                        let attachment = streamKind.isGridLayout ? asset.gridLayoutAttachment : asset.oneColumnAttachment
                    {
                        let manager = SDWebImageManager.sharedManager()
                        manager.downloadImageWithURL(attachment.url,
                            options: SDWebImageOptions.LowPriority,
                            progress: { (_, _) in }, completed: { (_, _, _, _, _) in})
                    }
                }
            }
        }
    }
}
