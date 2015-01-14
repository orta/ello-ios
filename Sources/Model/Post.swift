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

    let postId: String
    let createdAt: NSDate
    let href: String
    let collapsed: Bool
    let content: [BodyElement]
    let token: String
    var author: User?
    let commentsCount: Int?
    let viewsCount: Int?
    let repostsCount: Int?

    init(postId: String, createdAt: NSDate, href: String, collapsed:Bool, content: [BodyElement], token: String, commentsCount: Int?, viewsCount: Int?, repostsCount: Int?) {
        self.postId = postId
        self.createdAt = createdAt
        self.href = href
        self.collapsed = collapsed
        self.content = content
        self.token = token
        self.commentsCount = commentsCount
        self.viewsCount = viewsCount
        self.repostsCount = repostsCount
    }

    override class func fromJSON(data:[String: AnyObject], linked: [String:[AnyObject]]?) -> JSONAble {
        let linkedData = JSONAble.linkItems(data, linked: linked)
        let json = JSON(linkedData)
        let postId = json["id"].stringValue
        var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
        let href = json["href"].stringValue
        let collapsed = json["collapsed"].boolValue
        let token = json["token"].stringValue
        let viewsCount = json["views_count"].int
        let commentsCount = json["comments_count"].int
        let repostsCount = json["reposts_count"].int

        let post = Post(postId: postId, createdAt: createdAt, href: href, collapsed: collapsed, content: bodyElements(json), token: token, commentsCount: commentsCount, viewsCount: viewsCount, repostsCount: repostsCount)

        if let authorDict = json["author"].object as? [String: AnyObject] {
            post.author = User.fromJSON(authorDict, linked: linked) as? User
        }

        return post
    }

    class private func bodyElements(json:JSON) -> [BodyElement] {
        let body = json["content"].object as [AnyObject]
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
