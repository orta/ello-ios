//
//  ModelHelper.swift
//  Ello
//
//  Created by Sean on 3/4/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct ModelHelper {

    static func cellsForTwoPostsWithComments() -> [StreamCellItem] {
        return  ModelHelper.cellsForPostWithComments("555") +
                ModelHelper.cellsForPostWithComments("666")
    }

    static func cellsForPostWithComments(postId: String) -> [StreamCellItem] {
        let post = ModelHelper.stubPost(postId, contentCount: 5, summaryCount: 5)
        let comment = ModelHelper.stubComment("456", contentCount: 3, summaryCount: 3, parentPost: post)
        let postCellItems = StreamCellItemParser().parse([post], streamKind: .Friend)
        let commentCellItems = StreamCellItemParser().parse([comment], streamKind: .Friend)

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
}