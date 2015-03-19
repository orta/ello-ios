//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON


@objc protocol Authorable {
    var createdAt : NSDate { get }
    var groupId: String { get }
    var author : User? { get }
}

let PostVersion = 1

final class Post: JSONAble, Authorable, NSCoding {
    let version: Int = PostVersion
    var assets: [String:Asset]?
    var author: User?
    let collapsed: Bool
    let commentsCount: Int?
    var content: [Regionable]?
    var createdAt: NSDate
    var groupId:String {
        get { return postId }
    }
    var shareLink:String? {
        get {
            if let author = self.author {
                return "\(ElloURI.baseURL)/\(author.username)/post/\(self.token)"
            }
            else {
                return nil
            }
        }
    }
    let href: String
    let postId: String
    let repostsCount: Int?
    var summary: [Regionable]?
    let token: String
    let viewsCount: Int?
    var comments: [Comment]

// MARK: Initialization

    init(assets: [String:Asset]?,
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
    }

// MARK: NSCoding

    required init(coder decoder: NSCoder) {
        self.assets = decoder.decodeObjectForKey("assets") as? [String:Asset]
        self.author = decoder.decodeObjectForKey("author") as? User
        if decoder.containsValueForKey("collapsed") {
            self.collapsed = decoder.decodeBoolForKey("collapsed")
        }
        else {
            self.collapsed = false
        }

        if decoder.containsValueForKey("commentsCount") {
            self.commentsCount = Int(decoder.decodeIntForKey("commentsCount"))
        }

        if let content = decoder.decodeObjectForKey("content") as? [Regionable] {
            self.content = content
        }

        self.createdAt = decoder.decodeObjectForKey("createdAt") as NSDate
        self.href = decoder.decodeObjectForKey("href") as String
        self.postId = decoder.decodeObjectForKey("postId") as String

        if decoder.containsValueForKey("repostsCount") {
            self.repostsCount = Int(decoder.decodeIntForKey("repostsCount"))
        }

        if let summary = decoder.decodeObjectForKey("summary") as? [Regionable] {
            self.summary = summary
        }

        self.token = decoder.decodeObjectForKey("token") as String

        if decoder.containsValueForKey("viewsCount") {
            self.viewsCount = Int(decoder.decodeIntForKey("viewsCount"))
        }

        if decoder.containsValueForKey("comments") {
            self.comments = decoder.decodeObjectForKey("comments") as [Comment]
        }
        else {
            self.comments = [Comment]()
        }
    }

    func encodeWithCoder(encoder: NSCoder) {
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

     override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
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

    override var description : String {
        return "Post:\n\tpostId:\(self.postId)"
    }
}

