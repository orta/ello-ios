//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON
import YapDatabase

@objc
public protocol Authorable {
    var createdAt : NSDate { get }
    var groupId: String { get }
    var author: User? { get }
}

let PostVersion = 1

public final class Post: JSONAble, Authorable {

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let authorId: String
    public let href: String
    public let token: String
    public let contentWarning: String
    public let allowComments: Bool
    public let summary: [Regionable]
    // optional
    public var content: [Regionable]?
    public var repostContent: [Regionable]?
    public var repostId: String?
    public var repostPath: String?
    public var repostViaId: String?
    public var repostViaPath: String?
    public var viewsCount: Int?
    public var commentsCount: Int?
    public var repostsCount: Int?
    // links
    public var assets: [Asset]? {
        return getLinkArray("assets") as? [Asset]
    }
    public var author: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.authorId, inCollection: MappingType.UsersType.rawValue) as? User
    }
    public var repostAuthor: User? {
        return getLinkObject("repost_author") as? User
    }
    // nested resources
    public var comments: [Comment]? {
        return getLinkArray(MappingType.CommentsType.rawValue) as? [Comment]
    }
    // links post with comments
    public var groupId:String { return id }
    // computed properties
    public var shareLink:String? {
        get {
            if let author = self.author {
                return "\(ElloURI.baseURL)/\(author.username)/post/\(self.token)"
            }
            else {
                return nil
            }
        }
    }
    public var collapsed: Bool { return self.contentWarning != "" }
    private var commentCountNotification: NotificationObserver?
    public var isRepost: Bool {
        if let repostContent = self.repostContent {
            return repostContent.count > 0
        }
        return false
    }


// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        authorId: String,
        href: String,
        token: String,
        contentWarning: String,
        allowComments: Bool,
        summary: [Regionable]
        )
    {
        // active record
        self.id = id
        self.createdAt = createdAt
        // required
        self.authorId = authorId
        self.href = href
        self.token = token
        self.contentWarning = contentWarning
        self.allowComments = allowComments
        self.summary = summary
        super.init(version: PostVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.href = decoder.decodeKey("href")
        self.token = decoder.decodeKey("token")
        self.contentWarning = decoder.decodeKey("contentWarning")
        self.allowComments = decoder.decodeKey("allowComments")
        self.summary = decoder.decodeKey("summary")
        // optional
        self.content = decoder.decodeOptionalKey("content")
        self.repostContent = decoder.decodeOptionalKey("repostContent")
        self.repostId = decoder.decodeOptionalKey("repostId")
        self.repostPath = decoder.decodeOptionalKey("repostPath")
        self.repostViaId = decoder.decodeOptionalKey("repostViaId")
        self.repostViaPath = decoder.decodeOptionalKey("repostViaPath")
        self.viewsCount = decoder.decodeOptionalKey("viewsCount")
        self.commentsCount = decoder.decodeOptionalKey("commentsCount")
        self.repostsCount = decoder.decodeOptionalKey("repostsCount")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(authorId, forKey: "authorId")
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(token, forKey: "token")
        encoder.encodeObject(contentWarning, forKey: "contentWarning")
        encoder.encodeBool(allowComments, forKey: "allowComments")
        encoder.encodeObject(summary, forKey: "summary")
        // optional
        encoder.encodeObject(content, forKey: "content")
        encoder.encodeObject(repostContent, forKey: "repostContent")
        encoder.encodeObject(repostId, forKey: "repostId")
        encoder.encodeObject(repostPath, forKey: "repostPath")
        encoder.encodeObject(repostViaId, forKey: "repostViaId")
        encoder.encodeObject(repostViaPath, forKey: "repostViaPath")
        if let viewsCount = self.viewsCount {
            encoder.encodeInt64(Int64(viewsCount), forKey: "viewsCount")
        }
        if let commentsCount = self.commentsCount {
            encoder.encodeInt64(Int64(commentsCount), forKey: "commentsCount")
        }
        if let repostsCount = self.repostsCount {
            encoder.encodeInt64(Int64(repostsCount), forKey: "repostsCount")
        }
        super.encodeWithCoder(encoder)
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        var repostContent = RegionParser.regions("repost_content", json: json)
        // create post
        var post = Post(
            id: json["id"].stringValue,
            createdAt: json["created_at"].stringValue.toNSDate()!,
            authorId: json["author_id"].stringValue,
            href: json["href"].stringValue,
            token: json["token"].stringValue,
            contentWarning: json["content_warning"].stringValue,
            allowComments: json["allow_comments"].boolValue,
            summary: RegionParser.regions("summary", json: json)
            )
        // optional
        post.content = RegionParser.regions("content", json: json, isRepostContent: repostContent.count > 0)
        post.repostContent = repostContent
        post.repostId = json["repost_id"].string
        post.repostPath = json["repost_path"].string
        post.repostViaId = json["repost_via_id"].string
        post.repostViaPath = json["repost_via_path"].string
        post.viewsCount = json["views_count"].int
        post.commentsCount = json["comments_count"].int
        post.repostsCount = json["reposts_count"].int
        // links
        post.links = data["links"] as? [String: AnyObject]
        // store self in collection
        if !fromLinked {
            ElloLinkedStore.sharedInstance.setObject(post, forKey: post.id, inCollection: MappingType.PostsType.rawValue)
        }
        return post
    }
}
