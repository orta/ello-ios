//
//  Comment.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON

let CommentVersion = 1

public final class Comment: JSONAble, Authorable, NSCoding {

    public let version: Int = CommentVersion

    public var author: Userlike?
    public let commentId: String
    public var content: [Regionable]?
    public var createdAt: NSDate
    public var groupId:String {
        get {
            return parentPost?.postId ?? ""
        }
    }
    public var parentPost: Post?
    public var summary: [Regionable]?

// MARK: Initialization

    public init(author: Userlike?,
        commentId: String,
        content: [Regionable]?,
        createdAt: NSDate,
        parentPost: Post?,
        summary: [Regionable]? )
    {
        self.author = author
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.parentPost = parentPost
        self.summary = summary
    }


// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.author = decoder.decodeOptionalKey("author")
        self.commentId = decoder.decodeKey("commentId")
        self.createdAt = decoder.decodeKey("createdAt")
        self.parentPost = decoder.decodeOptionalKey("parentPost")
        self.summary = decoder.decodeOptionalKey("summary")
        self.content = decoder.decodeOptionalKey("content")
    }

    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.author, forKey: "author")
        encoder.encodeObject(self.commentId, forKey: "commentId")
        if let content = self.content {
            encoder.encodeObject(content, forKey: "content")
        }
        encoder.encodeObject(self.createdAt, forKey: "createdAt")
        encoder.encodeObject(self.parentPost, forKey: "parentPost")
        if let summary = self.summary {
            encoder.encodeObject(summary, forKey: "summary")
        }
    }

// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        var commentId = json["id"].stringValue
        var createdAt = json["created_at"].stringValue.toNSDate()!

        var links = [String: AnyObject]()
        var parentPost:Post?
        var author: User?
        var content: [Regionable]?
        var summary: [Regionable]?
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
            parentPost = links["parent_post"] as? Post
            //            var assets = links["assets"] as? [String:JSONAble]
            content = RegionParser.regions("content", json: json)
            summary = RegionParser.regions("summary", json: json)
        }

        return Comment(
            author: author,
            commentId: commentId,
            content: content,
            createdAt: createdAt,
            parentPost: parentPost,
            summary: summary
        )
    }

    public class func newCommentForPost(post: Post, currentUser: Userlike) -> Comment {
        return Comment(
            author: currentUser,
            commentId: "nil",
            content: nil,
            createdAt: NSDate(),
            parentPost: post,
            summary: nil
        )
    }
}
