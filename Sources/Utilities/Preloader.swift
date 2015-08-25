//
//  Preloader.swift
//  Ello
//
//  Created by Sean on 4/25/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import PINRemoteImage

public struct Preloader {

    // public so that we can swap out a fake in specs
    public var manager = PINRemoteImageManager.sharedImageManager()

    public init(){}

    public func preloadImages(jsonables: [JSONAble], streamKind: StreamKind) {

        for jsonable in jsonables {

            // activities avatar
            if  let activity = jsonable as? Activity,
                let authorable = activity.subject as? Authorable,
                let author = authorable.author,
                let avatarURL = author.avatarURL
            {
                preloadUrl(avatarURL)
            }

            // post / comment avatars
            else if let authorable = jsonable as? Authorable,
                    let author = authorable.author,
                    let avatarURL = author.avatarURL
            {
                preloadUrl(avatarURL)
            }

            // user's posts avatars
            else if let user = jsonable as? User,
                    let posts = user.posts
            {
                if let userAvatarURL = user.avatarURL {
                    preloadUrl(userAvatarURL)
                }

                for post in posts {
                    if  let author = post.author,
                        let avatarURL = author.avatarURL
                        {
                            preloadUrl(avatarURL)
                        }
                }
            }

            // activity image regions
            if  let activity = jsonable as? Activity,
                let post = activity.subject as? Post
            {
                preloadImagesinPost(post, streamKind: streamKind)
            }

            // post image regions
            else if let post = jsonable as? Post {
                preloadImagesinPost(post, streamKind: streamKind)
            }

            // comment image regions
            else if let comment = jsonable as? Comment {
                preloadImagesInRegions(comment.content, streamKind: streamKind)
            }

            // user's posts image regions
            else if let user = jsonable as? User,
                    let posts = user.posts
            {
                for post in posts {
                    preloadImagesinPost(post, streamKind: streamKind)
                }
            }

            // TODO: account for discovery when the api includes assets in the discovery
            // responses
        }
    }

    private func preloadUserAvatar(post: Post, streamKind: StreamKind) {
        if let content = streamKind.isGridLayout ? post.summary: post.content {
            for region in content {
                if let imageRegion = region as? ImageRegion,
                    let asset = imageRegion.asset,
                    let attachment = streamKind.isGridLayout ? asset.gridLayoutAttachment : asset.oneColumnAttachment
                {
                    preloadUrl(attachment.url)
                }
            }
        }
    }

    private func preloadImagesinPost(post: Post, streamKind: StreamKind) {
        if let content = streamKind.isGridLayout ? post.summary: post.content {
            preloadImagesInRegions(content, streamKind: streamKind)
        }
    }

    private func preloadImagesInRegions(regions: [Regionable], streamKind: StreamKind) {
        for region in regions {
            if  let imageRegion = region as? ImageRegion,
                let asset = imageRegion.asset,
                let attachment = streamKind.isGridLayout ?
                    asset.gridLayoutAttachment : asset.oneColumnAttachment
            {
                preloadUrl(attachment.url)
            }
        }
    }

    private func preloadUrl(url: NSURL) {
        if !url.hasGifExtension {
            manager.prefetchImageWithURL(url, options: PINRemoteImageManagerDownloadOptions.DownloadOptionsNone)
        }
    }
}
