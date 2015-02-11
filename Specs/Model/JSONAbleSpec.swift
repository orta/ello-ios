//
//  JSONAbleSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

class JSONAbleSpec: QuickSpec {
    override func spec() {

        describe("+parseLinks:model:") {

            var data = stubbedJSONDataWithLinked("posts", "posts")
            var post:Post?

            beforeEach {
                data = stubbedJSONDataWithLinked("posts", "posts")

                let json = JSON(data)
                let postId = json["id"].stringValue
                var createdAt:NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
                let href = json["href"].stringValue
                let collapsed = json["collapsed"].boolValue
                let token = json["token"].stringValue
                let viewsCount = json["views_count"].int
                let commentsCount = json["comments_count"].int
                let repostsCount = json["reposts_count"].int

                post = Post(postId: postId, createdAt: createdAt, href: href, collapsed: collapsed, content: nil, token: token, commentsCount: commentsCount, viewsCount: viewsCount, repostsCount: repostsCount)
            }

            afterEach {
                Store.store.removeAll(keepCapacity: false)
            }

            it("parses single objects") {
                let links = data["links"] as [String: AnyObject]
                JSONAble.parseLinks(links, model: post!)
                let author: User = post!.links["author"] as User
                expect(author).to(beAKindOf(User.self))
            }

        }
    }
}

