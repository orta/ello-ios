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

        var data: [String: AnyObject]!
        var links: [String: AnyObject]!

        describe("+parseLinks(links:model:)") {

            xit("is tested in User/PostSpec") {

            }

            describe("with a post") {
                var post: Post!

                beforeEach {
                    data = stubbedJSONData("posts", "posts")
                    links = data["links"] as [String: AnyObject]
                    let json = JSON(data)
                    let postId = json["id"].stringValue
                    var createdAt: NSDate = json["created_at"].stringValue.toNSDate() ?? NSDate()
                    let href = json["href"].stringValue
                    let collapsed = json["collapsed"].boolValue
                    let token = json["token"].stringValue
                    let viewsCount = json["views_count"].int
                    let commentsCount = json["comments_count"].int
                    let repostsCount = json["reposts_count"].int

                    post = Post(postId: postId, createdAt: createdAt, href: href, collapsed: collapsed, content: nil, token: token, commentsCount: commentsCount, viewsCount: viewsCount, repostsCount: repostsCount)
                }

                it("creates an author") {
                    JSONAble.parseLinks(links, model: post)
                    let author = post.links["author"] as User
                    expect(author).to(beAKindOf(User.self))
                }

                it("creates an assets object") {
                    JSONAble.parseLinks(links, model: post)
                    let assets = post.links["assets"] as [String: AnyObject]
                    expect(assets["85"]).notTo(beNil())
                }
            }

            describe("with a user") {
                var user: User!

                beforeEach {
                    data = stubbedJSONData("user", "users")
                    links = data["links"] as [String: AnyObject]
                    let json = JSON(data)
                    let name = json["name"].stringValue
                    let userId = json["id"].stringValue
                    let username = json["username"].stringValue


                    let experimentalFeatures = json["experimental_features"].boolValue
                    let href = json["href"].stringValue
                    let relationshipPriority = json["relationship_priority"].stringValue

                    var avatarURL:NSURL?

                    if var avatar = json["avatar"].object as? [String:[String:AnyObject]] {
                        if let avatarPath = avatar["large"]?["url"] as? String {
                            avatarURL = NSURL(string: avatarPath, relativeToURL: NSURL(string: "https://ello.co"))
                        }
                    }

                    user = User(name: name,
                        userId: userId,
                        username: username,
                        avatarURL:avatarURL,
                        experimentalFeatures: experimentalFeatures,
                        href:href,
                        relationshipPriority:relationshipPriority,
                        followersCount: nil,
                        postsCount: nil,
                        followingCount: nil)
                }

                it("creates a posts array") {
                    JSONAble.parseLinks(links, model: user)
                    let posts = user.links["posts"] as [Post]
                    expect(posts.count) >= 1
                    expect(posts[0]).to(beAKindOf(Post.self))
                }
            }
        }
    }
}

