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
    public let version = CommentVersion

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let postId: String
    public let content: [Regionable]
    // links
    public var assets: [Asset]? {
        if let assets = getLinkArray("assets") as? [Asset] {
            return assets
        }
        return nil
    }
    public var author: User? { return getLinkObject("author") as? User }
    public var parentPost: Post? {
        var post: Post? = nil
        ElloLinkedStore.sharedInstance.database.newConnection().readWithBlock { transaction in
            post = transaction.objectForKey(self.postId, inCollection: MappingType.PostsType.rawValue) as? Post
        }
        if let parentPost = post { return post }
        return getLinkObject("parent_post") as? Post
    }

    // computed properties
    public var groupId:String {
        get { return postId }
    }

// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        postId: String,
        content: [Regionable])
    {
        self.id = id
        self.createdAt = createdAt
        self.postId = postId
        self.content = content
        super.init()
    }


// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt") 
        // required
        self.postId = decoder.decodeKey("postId")
        self.content = decoder.decodeKey("content")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(postId, forKey: "postId")
        encoder.encodeObject(content, forKey: "content")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        // create comment
        var comment = Comment(
            id: json["id"].stringValue,
            createdAt: json["created_at"].stringValue.toNSDate()!,
            postId: json["post_id"].stringValue,
            content: RegionParser.regions("content", json: json)
            )
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
            postId: post.id,
            content: [Regionable]()
        )
        comment.addLinkObject("author", key: currentUser.id, collection: MappingType.UsersType.rawValue)
        comment.addLinkObject("parent_post", key: post.id, collection: MappingType.PostsType.rawValue)
        return comment
    }
}
