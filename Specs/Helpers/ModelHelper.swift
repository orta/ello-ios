//
//  ModelHelper.swift
//  Ello
//
//  Created by Sean on 3/4/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct ModelHelper {

    static func allCellTypes() -> [StreamCellItem] {
        let parser = StreamCellItemParser()
        // models
        let post = ModelHelper.stubPost("555", contentCount: 1, summaryCount: 1)
        let comment = ModelHelper.stubComment("456", contentCount: 1, summaryCount: 1, parentPost: post)
        let user = ModelHelper.stubUser(["userId": "420"])
        // cell items
        let postCellItems = parser.parse([post], streamKind: .Friend)
        let commentCellItems = parser.parse([comment], streamKind: .Friend)
        let profileHeaderCellItem = StreamCellItem(jsonable: user, type: StreamCellType.ProfileHeader, data: nil, oneColumnCellHeight: 320.0, multiColumnCellHeight: 0.0, isFullWidth: true)
        let userListItemCell = parser.parse([user], streamKind: StreamKind.UserList(endpoint: ElloAPI.UserStreamFollowers(userId:"420"), title: "Followers"))

        return postCellItems + commentCellItems + [profileHeaderCellItem] + userListItemCell
    }

    static func cellsForTwoPostsWithComments() -> [StreamCellItem] {
        return  ModelHelper.cellsForPostWithComments("555") +
                ModelHelper.cellsForPostWithComments("666")
    }

    static func cellsForPostWithComments(postId: String) -> [StreamCellItem] {
        let post = ModelHelper.stubPost(postId, contentCount: 5, summaryCount: 5)
        let comment = ModelHelper.stubComment("456", contentCount: 3, summaryCount: 3, parentPost: post)
        let parser = StreamCellItemParser()
        let postCellItems = parser.parse([post], streamKind: .Friend)
        let commentCellItems = parser.parse([comment], streamKind: .Friend)

        return postCellItems + commentCellItems
    }

    static func stubComment(commentId: String, contentCount: Int, summaryCount: Int, parentPost: Post?) -> Comment {

        var content = [Regionable]()
        for index in 0..<contentCount {
            content.append(TextRegion(content: "Lorem Ipsum"))
        }

        var summary = [Regionable]()
        for index in 0..<summaryCount {
            summary.append(TextRegion(content: "Lorem Ipsum"))
        }

        return Comment(
            author: nil,
            commentId: commentId,
            content: content,
            createdAt: NSDate(),
            parentPost:parentPost,
            summary: summary)
    }


    static func stubPost(postId: String, contentCount: Int, summaryCount: Int) -> Post {

        var content = [Regionable]()
        for index in 0..<contentCount {
            content.append(TextRegion(content: "Lorem Ipsum"))
        }

        var summary = [Regionable]()
        for index in 0..<summaryCount {
            summary.append(TextRegion(content: "Lorem Ipsum"))
        }

        return Post(
            assets: nil, 
            author: nil,
            collapsed: false,
            commentsCount: nil,
            content: content,
            createdAt: NSDate(),
            href: "foo",
            postId: postId,
            repostsCount: nil,
            summary: summary,
            token: "bar",
            viewsCount: nil)
    }

    static func stubUser(values: [String: AnyObject]) -> User {
        return User(
            avatarURL: (values["avatarURL"] as? NSURL) ?? nil,
            coverImageURL: (values["coverImageURL"] as? NSURL) ?? nil,
            experimentalFeatures: (values["experimentalFeatures"] as? Bool) ?? false,
            followersCount: (values["followersCount"] as? Int) ?? 0,
            followingCount: (values["followingCount"] as? Int) ?? 0,
            href: (values["href"] as? String) ?? "href",
            name: (values["name"] as? String) ?? "name",
            posts: (values["posts"] as? [Post]) ?? [],
            postsCount: (values["postsCount"] as? Int) ?? 0,
            relationshipPriority: (values["relationshipPriority"] as? String) ?? "none",
            userId: (values["userId"] as? String) ?? "1",
            username: (values["username"] as? String) ?? "username",
            formattedShortBio: (values["formattedShortBio"] as? String) ?? "formattedShortBio"
        )
    }
}