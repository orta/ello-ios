//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON


public let UpdatePostCommentCountNotification = TypedNotification<Comment>(name: "UpdatePostCommentCountNotification")


@objc
public protocol Authorable {
    var createdAt : NSDate { get }
    var groupId: String { get }
    var author: User? { get }
}

let PostVersion = 1

public final class Post: JSONAble, Authorable, NSCoding {
    public let version: Int = PostVersion
    var assets: [String:Asset]?
    public var author: User?
    public var collapsed: Bool
    public var commentsCount: Int?
    public var content: [Regionable]?
    public var createdAt: NSDate
    public var groupId:String {
        get { return postId }
    }
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
    public let href: String
    public let postId: String
    public let repostsCount: Int?
    public var summary: [Regionable]?
    public let token: String
    public let viewsCount: Int?
    public var comments: [Comment]

    private var commentCountNotification: NotificationObserver?

// MARK: Initialization

    public init(assets: [String:Asset]?,
        author: User?,
        collapsed: Bool,
        commentsCount: Int?,
        content: [Regionable]?,
        createdAt: NSDate,
        href: String,
        postId: String,
        repostsCount: Int?,
        summary: [Regionable]?,
        token: String,
        viewsCount: Int?,
        comments: [Comment])
    {
        self.assets = assets
        self.author = author
        self.collapsed = collapsed
        self.commentsCount = commentsCount
        self.content = content
        self.createdAt = createdAt
        self.href = href
        self.postId = postId
        self.repostsCount = repostsCount
        self.summary = summary
        self.token = token
        self.viewsCount = viewsCount
        self.comments = comments
        super.init()
        self.registerNotifications()
    }

    deinit {
        self.unregisterNotifications()
    }

    private func registerNotifications() {
        commentCountNotification = NotificationObserver(notification: UpdatePostCommentCountNotification) { comment in
            if let postId = comment.parentPost?.postId {
                if postId == self.postId {
                    if let count = self.commentsCount {
                        self.commentsCount = count + 1
                    }
                    else {
                        self.commentsCount = 1
                    }
                }
            }
        }
    }

    private func unregisterNotifications() {
        if let commentCountNotification = commentCountNotification {
            commentCountNotification.removeObserver()
            self.commentCountNotification = nil
        }
    }

// MARK: NSCoding

    required public init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.assets = decoder.decodeOptionalKey("assets")
        self.author = decoder.decodeOptionalKey("author")
        self.collapsed = decoder.decodeKey("collapsed")
        self.commentsCount = decoder.decodeOptionalKey("commentsCount")
        self.content = decoder.decodeOptionalKey("content")
        self.createdAt = decoder.decodeKey("createdAt")
        self.href = decoder.decodeKey("href")
        self.postId = decoder.decodeKey("postId")
        self.repostsCount = decoder.decodeOptionalKey("repostsCount")
        self.summary = decoder.decodeOptionalKey("summary")
        self.token = decoder.decodeKey("token")
        self.viewsCount = decoder.decodeOptionalKey("viewsCount")
        self.comments = decoder.decodeKey("comments")
        super.init()
        self.registerNotifications()
    }

    public func encodeWithCoder(encoder: NSCoder) {
        if let assets = self.assets {
            encoder.encodeObject(assets, forKey: "assets")
        }
        if let author = self.author {
            encoder.encodeObject(author, forKey: "author")
        }
        encoder.encodeBool(self.collapsed, forKey: "collapsed")
        if let commentsCount = self.commentsCount {
            encoder.encodeInt64(Int64(commentsCount), forKey: "commentsCount")
        }
        encoder.encodeObject(self.createdAt, forKey: "createdAt")
        encoder.encodeObject(self.href, forKey: "href")
        encoder.encodeObject(self.postId, forKey: "postId")
        if let repostsCount = self.repostsCount {
            encoder.encodeInt64(Int64(repostsCount), forKey: "repostsCount")
        }
        encoder.encodeObject(self.token, forKey: "token")
        if let viewsCount = self.viewsCount {
            encoder.encodeInt64(Int64(viewsCount), forKey: "viewsCount")
        }

        if let content = self.content {
            encoder.encodeObject(content, forKey: "content")
        }

        if let summary = self.summary {
            encoder.encodeObject(summary, forKey: "summary")
        }
        encoder.encodeObject(self.comments, forKey: "comments")
    }

// MARK: JSONAble

     override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let postId = json["id"].stringValue
        var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
        let href = json["href"].stringValue
        let collapsed = json["collapsed"].boolValue
        let token = json["token"].stringValue
        let viewsCount = json["views_count"].int
        let commentsCount = json["comments_count"].int
        let repostsCount = json["reposts_count"].int
        var links = [String: AnyObject]()
        var author: User?
        var content: [Regionable]?
        var summary: [Regionable]?
        var postComments = [Comment]()
        if let linksNode = data["links"] as? [String: AnyObject] {
            links = ElloLinkedStore.parseLinks(linksNode)
            author = links["author"] as? User
//            var assets = links["assets"] as? [String:JSONAble]
            content = RegionParser.regions("content", json: json)
            summary = RegionParser.regions("summary", json: json)
            if let comments = links["comments"] as? [Comment] {
                postComments = comments
            }
        }

        return Post(
            assets: nil,
            author: author,
            collapsed: collapsed,
            commentsCount: commentsCount,
            content: content,
            createdAt: createdAt,
            href: href,
            postId: postId,
            repostsCount: repostsCount,
            summary: summary,
            token: token,
            viewsCount: viewsCount,
            comments: postComments
        )
    }

    override public var description : String {
        return "Post:\n\tpostId:\(self.postId)"
    }
}

