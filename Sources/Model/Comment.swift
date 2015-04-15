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
    public let version: Int = CommentVersion

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let postId: String
    public let content: [Regionable]
    // links
    public var assets: [String: Asset]?
    public var author: User? { return getLinkObject("author") as? User }
    public var parentPost: Post? { return getLinkObject("parent_post") as? Post }
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
        // links
        self.assets = decoder.decodeOptionalKey("assets")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(postId, forKey: "postId")
        encoder.encodeObject(content, forKey: "content")
        // links
        encoder.encodeObject(assets, forKey: "assets")
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        // active record
        let id = json["id"].stringValue
        let createdAt = json["created_at"].stringValue.toNSDate()!
        // required
        let postId = json["post_id"].stringValue
        let content = RegionParser.regions("content", json: json)
        // create post
        var comment = Comment(
            id: id,
            createdAt: createdAt,
            postId: postId,
            content: content
            )
        // links
        var links = [String: AnyObject]()
        var assets =  [String: Asset]()
        var author: User?
        var parentPost:Post?
//        if let linksNode = data["links"] as? [String: AnyObject] {
//            links = ElloLinkedStore.sharedInstance.parseLinks(linksNode)
//            comment.assets = links["assets"] as? [String: Asset]
//            comment.author = links["author"] as? User
//            comment.parentPost = links["parent_post"] as? Post
//        }
        // links
        comment.links = data["links"] as? [String: AnyObject]
        // store self in collection
        ElloLinkedStore.sharedInstance.setObject(comment, forKey: comment.id, inCollection: MappingType.CommentsType.rawValue)
        return comment
    }

    public class func newCommentForPost(post: Post, currentUser: User) -> Comment {
        var comment = Comment(
            id: "nil",
            createdAt: NSDate(),
            postId: post.id,
            content: [Regionable]()
        )
        return comment
    }
}
