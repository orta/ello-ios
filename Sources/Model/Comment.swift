//
//  Comment.swift
//  Ello
//
//  Created by Sean Dougherty on 12/1/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON

let CommentVersion = 1

public final class Comment: JSONAble, Authorable {

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let authorId: String
    public let postId: String
    public let content: [Regionable]
    // optional
    public var summary: [Regionable]?
    // links
    public var assets: [Asset]? {
        return getLinkArray("assets") as? [Asset]
    }
    public var author: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.authorId, inCollection: MappingType.UsersType.rawValue) as? User
    }
    public var parentPost: Post? {
        return ElloLinkedStore.sharedInstance.getObject(self.postId, inCollection: MappingType.PostsType.rawValue) as? Post
    }
    // computed properties
    public var groupId: String {
        get { return postId }
    }
    // to show hide in the stream
    public var loadedFromPostId: String

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        authorId: String,
        postId: String,
        content: [Regionable])
    {
        self.id = id
        self.createdAt = createdAt
        self.authorId = authorId
        self.postId = postId
        self.content = content
        self.loadedFromPostId = postId
        super.init(version: CommentVersion)
    }


// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.postId = decoder.decodeKey("postId")
        self.content = decoder.decodeKey("content")
        self.loadedFromPostId = decoder.decodeKey("loadedFromPostId")
        // optional
        self.summary = decoder.decodeOptionalKey("summary")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(authorId, forKey: "authorId")
        encoder.encodeObject(postId, forKey: "postId")
        encoder.encodeObject(content, forKey: "content")
        encoder.encodeObject(loadedFromPostId, forKey: "loadedFromPostId")
        // optional
        encoder.encodeObject(summary, forKey: "summary")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        // create comment
        var comment = Comment(
            id: json["id"].stringValue,
            createdAt: json["created_at"].stringValue.toNSDate()!,
            authorId: json["author_id"].stringValue,
            postId: json["post_id"].stringValue,
            content: RegionParser.regions("content", json: json)
            )
        // optional
        comment.summary = RegionParser.regions("summary", json: json)
        // links
        comment.links = data["links"] as? [String: AnyObject]
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        }
        return comment
    }

    public class func newCommentForPost(post: Post, currentUser: User) -> Comment {
        var comment = Comment(
            id: NSUUID().UUIDString,
            createdAt: NSDate(),
            authorId: currentUser.id,
            postId: post.id,
            content: [Regionable]()
        )
        return comment
    }
}
