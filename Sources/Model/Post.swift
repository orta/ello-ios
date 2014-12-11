//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post: JSONAble {

    enum BodyElementTypes: String {
        case Text = "text"
        case Image = "image"
        case Unknown = "Unknown"
    }

    class BodyElement {
        let type:BodyElementTypes
        init(type: BodyElementTypes) {
            self.type = type
        }
    }

    class UnknownBodyElement : BodyElement {
        init() {
            super.init(type: BodyElementTypes.Unknown)
        }
    }

    class ImageBodyElement : BodyElement {
        let assetId:Int
        let via:String
        let alt:String
        let url:NSURL?

        init(assetId: Int, via: String, alt: String, url:NSURL?) {
            self.assetId = assetId
            self.via = via
            self.alt = alt
            self.url = url
            super.init(type: BodyElementTypes.Image)
        }
    }

    class TextBodyElement : BodyElement {
        let content:String

        init(content: String) {
            self.content = content
            super.init(type: BodyElementTypes.Text)
        }
    }

    dynamic let postId: Int
    dynamic let commentCount: Int
    dynamic let viewedCount: Int
    dynamic let body: [BodyElement]
    dynamic let content: [String]
    dynamic let summary: [String]
    dynamic let token: String

    dynamic let createdAt: NSDate
    dynamic var author: User?

    init(body: [BodyElement], createdAt: NSDate, postId: Int, content: [String], summary: [String], token: String, commentCount: Int, viewedCount: Int) {
        self.body = body
        self.createdAt = createdAt
        self.postId = postId
        self.content = content
        self.summary = summary
        self.token = token
        self.commentCount = commentCount
        self.viewedCount = viewedCount
    }

    override class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)

        let content = json["content"].object as [String]
        let summary = json["summary"].object as [String]
        let token = json["token"].stringValue
        let postId = json["id"].intValue
        let viewedCount = json["viewed_count"].intValue
        let commentCount = json["comment_count"].intValue

        var createdAt:NSDate = dateFromServerString(json["created_at"].stringValue) ?? NSDate()

        let post = Post(body: bodyElements(json), createdAt: createdAt, postId: postId, content: content, summary: summary, token: token, commentCount: commentCount, viewedCount: viewedCount)

        if let authorDict = json["author"].object as? [String: AnyObject] {
            post.author = User.fromJSON(authorDict) as? User
        }

        return post
    }

    class private func bodyElements(json:JSON) -> [BodyElement] {
        let body = json["body"].object as [AnyObject]
        return body.map { (bodyDict) -> BodyElement in

            let kind = BodyElementTypes(rawValue: bodyDict["kind"] as String) ?? BodyElementTypes.Unknown
            let data = bodyDict["data"]
            switch kind {
            case .Text:
                let data = data as String
                return TextBodyElement(content: data)
            case .Image:
                let data = data as [String:AnyObject]
                let assetId = data["asset_id"] as Int
                let via = data["via"] as String
                let alt = data["alt"] as? String ?? ""
                let url = data["url"] as String
                return ImageBodyElement(assetId: assetId, via: via, alt: alt, url: NSURL(string: url)!)
            case .Unknown:
                return UnknownBodyElement()
            }
        }
    }

    override var description : String {
        return "Post:\n\tpostId:\(self.postId)"
    }
}
