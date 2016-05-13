//
//  StreamKindSpec.swift
//  Ello
//
//  Created by Sean on 8/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class StreamKindSpec: QuickSpec {

    override func spec() {

        describe("StreamKind") {

            // TODO: convert these tests to the looping input/output style used on other enums

            describe("name") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).name) == "Discover"
                    expect(StreamKind.Following.name) == "Following"
                    expect(StreamKind.Starred.name) == "Starred"
                    expect(StreamKind.Notifications(category: "").name) == "Notifications"
                    expect(StreamKind.PostDetail(postParam: "param").name) == ""
                    expect(StreamKind.CurrentUserStream.name) == "Profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").name) == "meat"
                    expect(StreamKind.Unknown.name) == ""
                    expect(StreamKind.UserStream(userParam: "n/a").name) == ""
                }
            }

            describe("cacheKey") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).cacheKey) == "Discover"
                    expect(StreamKind.Following.cacheKey) == "Following"
                    expect(StreamKind.Starred.cacheKey) == "Starred"
                    expect(StreamKind.Notifications(category: "").cacheKey) == "Notifications"
                    expect(StreamKind.PostDetail(postParam: "param").cacheKey) == "PostDetail"
                    expect(StreamKind.CurrentUserStream.cacheKey) == "Profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").cacheKey) == "SearchForPosts"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").cacheKey) == "SimpleStream.meat"
                    expect(StreamKind.Unknown.cacheKey) == "unknown"
                    expect(StreamKind.UserStream(userParam: "n/a").cacheKey) == "UserStream"
                }
            }

            describe("lastViewedCreatedAtKey") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).lastViewedCreatedAtKey) == "Discover_createdAt"
                    expect(StreamKind.Following.lastViewedCreatedAtKey) == "Following_createdAt"
                    expect(StreamKind.Starred.lastViewedCreatedAtKey) == "Starred_createdAt"
                    expect(StreamKind.Notifications(category: "").lastViewedCreatedAtKey) == "Notifications_createdAt"
                    expect(StreamKind.PostDetail(postParam: "param").lastViewedCreatedAtKey) == "PostDetail_createdAt"
                    expect(StreamKind.CurrentUserStream.lastViewedCreatedAtKey) == "Profile_createdAt"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").lastViewedCreatedAtKey) == "SearchForPosts_createdAt"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").lastViewedCreatedAtKey) == "SimpleStream.meat_createdAt"
                    expect(StreamKind.Unknown.lastViewedCreatedAtKey) == "unknown_createdAt"
                    expect(StreamKind.UserStream(userParam: "n/a").lastViewedCreatedAtKey) == "UserStream_createdAt"
                }
            }

            describe("columnCount") {

                beforeEach {
                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.Starred.setIsGridView(false)
                    StreamKind.Notifications(category: "").setIsGridView(false)
                    StreamKind.PostDetail(postParam: "param").setIsGridView(false)
                    StreamKind.CurrentUserStream.setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    StreamKind.Unknown.setIsGridView(false)
                    StreamKind.UserStream(userParam: "n/a").setIsGridView(false)
                }

                it("is correct for all cases") {
                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(true)
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).columnCount) == 2

                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(false)
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).columnCount) == 1

                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.columnCount) == 1

                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.columnCount) == 2

                    StreamKind.Starred.setIsGridView(true)
                    expect(StreamKind.Starred.columnCount) == 2

                    StreamKind.Starred.setIsGridView(false)
                    expect(StreamKind.Starred.columnCount) == 1

                    expect(StreamKind.Notifications(category: "").columnCount) == 1
                    expect(StreamKind.PostDetail(postParam: "param").columnCount) == 1
                    expect(StreamKind.CurrentUserStream.columnCount) == 1

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").columnCount) == 2

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").columnCount) == 1

                    expect(StreamKind.Unknown.columnCount) == 1
                    expect(StreamKind.UserStream(userParam: "n/a").columnCount) == 1
                }
            }

            describe("tappingTextOpensDetail") {
                var followingIsGrid = false
                var starredIsGrid = false
                beforeEach {
                    followingIsGrid = StreamKind.Following.isGridView
                    starredIsGrid = StreamKind.Starred.isGridView
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.Starred.setIsGridView(true)
                }
                afterEach {
                    StreamKind.Following.setIsGridView(followingIsGrid)
                    StreamKind.Starred.setIsGridView(starredIsGrid)
                }

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).tappingTextOpensDetail) == true
                    expect(StreamKind.Following.tappingTextOpensDetail) == false
                    expect(StreamKind.Starred.tappingTextOpensDetail) == true
                    expect(StreamKind.Notifications(category: "").tappingTextOpensDetail) == true
                    expect(StreamKind.PostDetail(postParam: "param").tappingTextOpensDetail) == false
                    expect(StreamKind.CurrentUserStream.tappingTextOpensDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").tappingTextOpensDetail) == true
                    expect(StreamKind.Unknown.tappingTextOpensDetail) == true
                    expect(StreamKind.UserStream(userParam: "n/a").tappingTextOpensDetail) == false
                }
            }

            describe("endpoint") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).endpoint.path) == "/api/\(ElloAPI.apiVersion)/discover/posts/\(DiscoverType.Recommended.rawValue)"
                    expect(StreamKind.Following.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/friend"
                    expect(StreamKind.Starred.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/noise"
                    expect(StreamKind.Notifications(category: "").endpoint.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.PostDetail(postParam: "param").endpoint.path) == "/api/\(ElloAPI.apiVersion)/posts/param"
                    expect(StreamKind.PostDetail(postParam: "param").endpoint.parameters!["comment_count"] as? Bool) == true
                    expect(StreamKind.CurrentUserStream.endpoint.path) == "/api/\(ElloAPI.apiVersion)/profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").endpoint.path) == "/api/\(ElloAPI.apiVersion)/posts"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").endpoint.path) == "/api/\(ElloAPI.apiVersion)/users"
                    expect(StreamKind.Unknown.endpoint.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.UserStream(userParam: "n/a").endpoint.path) == "/api/\(ElloAPI.apiVersion)/users/n/a"
                }
            }

            describe("relationship") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).relationship) == RelationshipPriority.Null
                    expect(StreamKind.Following.relationship) == RelationshipPriority.Following
                    expect(StreamKind.Starred.relationship) == RelationshipPriority.Starred
                    expect(StreamKind.Notifications(category: "").relationship) == RelationshipPriority.Null
                    expect(StreamKind.PostDetail(postParam: "param").relationship) == RelationshipPriority.Null
                    expect(StreamKind.CurrentUserStream.relationship) == RelationshipPriority.Null
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").relationship) == RelationshipPriority.Null
                    expect(StreamKind.Unknown.relationship) == RelationshipPriority.Null
                    expect(StreamKind.UserStream(userParam: "n/a").relationship) == RelationshipPriority.Null
                }
            }

            describe("filter(_:viewsAdultContent:)") {
                // important but time consuming to implement this one, little by little!
                context("Discover") {

                    var postJsonables: [JSONAble] = []
                    var userJsonables: [JSONAble] = []

                    // trending is users, everything else are posts
                    beforeEach {
                        let post1 = Post.stub(["id": "post1", "isAdultContent" : true])
                        let post2 = Post.stub(["id": "post2"])
                        let post3 = Post.stub(["id": "post3"])

                        let user1 = User.stub(["mostRecentPost": post1])
                        let user2 = User.stub(["mostRecentPost": post2])
                        let user3 = User.stub(["mostRecentPost": post3])

                        postJsonables = [post1, post2, post3]
                        userJsonables = [user1, user2, user3]
                    }

                    context("User does NOT view NSFW content") {
                        it("filters out nsfw for Discover.Recommended") {
                            let kind = StreamKind.Discover(type: .Recommended, perPage: 5)
                            let filtered = kind.filter(postJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }

                        it("filters out nsfw for Discover.Trending") {
                            let kind = StreamKind.Discover(type: .Trending, perPage: 5)
                            let filtered = kind.filter(userJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }

                        it("filters out nsfw for Discover.Recent") {
                            let kind = StreamKind.Discover(type: .Recent, perPage: 5)

                            let filtered = kind.filter(postJsonables, viewsAdultContent: false) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }
                    }

                    context("User does view NSFW content") {
                        it("still filters out nsfw for Discover.Recommended") {
                            let kind = StreamKind.Discover(type: .Recommended, perPage: 5)
                            let filtered = kind.filter(postJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }

                        it("still filters out nsfw for Discover.Trending") {
                            let kind = StreamKind.Discover(type: .Trending, perPage: 5)
                            let filtered = kind.filter(userJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }

                        it("still filters out nsfw for Discover.Recent") {
                            let kind = StreamKind.Discover(type: .Recent, perPage: 5)

                            let filtered = kind.filter(postJsonables, viewsAdultContent: true) as! [Post]

                            expect(filtered.count) == 2
                            expect(filtered[0].id) == "post2"
                            expect(filtered[1].id) == "post3"
                        }
                    }
                }
            }

            describe("showStarButton") {

                let tests: [(Bool, StreamKind)] = [
                    (true, StreamKind.Discover(type: .Recommended, perPage: 1)),
                    (true, StreamKind.Following),
                    (true, StreamKind.Starred),
                    (false, StreamKind.Notifications(category: "")),
                    (true, StreamKind.PostDetail(postParam: "param")),
                    (true, StreamKind.CurrentUserStream),
                    (true, StreamKind.Unknown),
                    (true, StreamKind.UserStream(userParam: "n/a")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.UserStreamFollowers(userId: "12345"), title: "")),
                    (false, StreamKind.SimpleStream(endpoint: ElloAPI.AwesomePeopleStream, title: "")),
                    (false, StreamKind.SimpleStream(endpoint: ElloAPI.CommunitiesStream, title: "")),
                ]
                for (shouldStar, streamKind) in tests {
                    it("is \(shouldStar) for \(streamKind)") {
                        expect(streamKind.showStarButton) == shouldStar
                    }
                }
            }

            describe("clientSidePostInsertIndexPath(currentUserId:)") {
                let one = NSIndexPath(forItem: 1, inSection: 0)
                let tests: [(NSIndexPath?, StreamKind)] = [
                    (nil, StreamKind.Discover(type: .Recommended, perPage: 1)),
                    (one, StreamKind.Following),
                    (nil, StreamKind.Starred),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "12345"), title: "n/a")),
                    (nil, StreamKind.Notifications(category: "")),
                    (nil, StreamKind.PostDetail(postParam: "param")),
                    (one, StreamKind.CurrentUserStream),
                    (nil, StreamKind.Unknown),
                    (nil, StreamKind.UserStream(userParam: "n/a")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.UserStreamFollowers(userId: "54321"), title: "")),
                    (one, StreamKind.UserStream(userParam: "12345")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.UserStream(userParam: "54321"), title: "")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.AwesomePeopleStream, title: "")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.CommunitiesStream, title: "")),
                ]
                for (indexPath, streamKind) in tests {
                    it("is \(indexPath) for \(streamKind)") {

                        if(indexPath == nil) {
                            expect(streamKind.clientSidePostInsertIndexPath("12345")).to(beNil())
                        }
                        else {
                            expect(streamKind.clientSidePostInsertIndexPath("12345")) == indexPath
                        }
                    }
                }
            }

            describe("clientSideLoveInsertIndexPath") {
                let one = NSIndexPath(forItem: 1, inSection: 0)
                let tests: [(NSIndexPath?, StreamKind)] = [
                    (nil, StreamKind.Discover(type: .Recommended, perPage: 1)),
                    (nil, StreamKind.Following),
                    (nil, StreamKind.Starred),
                    (one, StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "12345"), title: "n/a")),
                    (nil, StreamKind.Notifications(category: "")),
                    (nil, StreamKind.PostDetail(postParam: "param")),
                    (nil, StreamKind.CurrentUserStream),
                    (nil, StreamKind.Unknown),
                    (nil, StreamKind.UserStream(userParam: "n/a")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.UserStreamFollowers(userId: "54321"), title: "")),
                    (nil, StreamKind.UserStream(userParam: "12345")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.UserStream(userParam: "54321"), title: "")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.AwesomePeopleStream, title: "")),
                    (nil, StreamKind.SimpleStream(endpoint: ElloAPI.CommunitiesStream, title: "")),
                ]
                for (indexPath, streamKind) in tests {
                    it("is \(indexPath) for \(streamKind)") {

                        if(indexPath == nil) {
                            expect(streamKind.clientSideLoveInsertIndexPath).to(beNil())
                        }
                        else {
                            expect(streamKind.clientSideLoveInsertIndexPath) == indexPath
                        }
                    }
                }
            }

            describe("isGridView") {

                beforeEach {
                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.Starred.setIsGridView(false)
                    StreamKind.Notifications(category: "").setIsGridView(false)
                    StreamKind.PostDetail(postParam: "param").setIsGridView(false)
                    StreamKind.CurrentUserStream.setIsGridView(false)
                    StreamKind.Following.setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(false)
                    StreamKind.Unknown.setIsGridView(false)
                    StreamKind.UserStream(userParam: "n/a").setIsGridView(false)
                }


                it("is correct for all cases") {
                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(true)
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).isGridView) == true

                    StreamKind.Discover(type: .Recommended, perPage: 1).setIsGridView(false)
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).isGridView) == false

                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.isGridView) == false

                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.isGridView) == true

                    StreamKind.Starred.setIsGridView(true)
                    expect(StreamKind.Starred.isGridView) == true

                    StreamKind.Starred.setIsGridView(false)
                    expect(StreamKind.Starred.isGridView) == false

                    expect(StreamKind.Notifications(category: "").isGridView) == false
                    expect(StreamKind.PostDetail(postParam: "param").isGridView) == false
                    expect(StreamKind.CurrentUserStream.isGridView) == false

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isGridView) == true

                    StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isGridView) == false

                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(true)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").isGridView) == true

                    StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").setIsGridView(false)
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").isGridView) == false

                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").isGridView) == false
                    expect(StreamKind.Unknown.isGridView) == false
                    expect(StreamKind.UserStream(userParam: "n/a").isGridView) == false
                }
            }



            describe("hasGridViewToggle") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).hasGridViewToggle) == true
                    expect(StreamKind.Following.hasGridViewToggle) == true
                    expect(StreamKind.Starred.hasGridViewToggle) == true
                    expect(StreamKind.Notifications(category: "").hasGridViewToggle) == false
                    expect(StreamKind.PostDetail(postParam: "param").hasGridViewToggle) == false
                    expect(StreamKind.CurrentUserStream.hasGridViewToggle) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").hasGridViewToggle) == true
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").hasGridViewToggle) == true
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").hasGridViewToggle) == false
                    expect(StreamKind.Unknown.hasGridViewToggle) == false
                    expect(StreamKind.UserStream(userParam: "n/a").hasGridViewToggle) == false
                }
            }

            describe("avatarHeight") {

                it("is correct for list mode") {
                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.avatarHeight) == 60.0
                }

                it("is correct for grid mode") {
                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.avatarHeight) == 30.0
                }
            }

            describe("contentForPost(:_)") {
                var post: Post!

                beforeEach {
                    post = Post.stub([
                        "id" : "768",
                        "content" : [TextRegion.stub([:]), TextRegion.stub([:])],
                        "summary" : [TextRegion.stub([:])]
                    ])
                }


                it("is correct for list mode") {
                    StreamKind.Following.setIsGridView(false)
                    expect(StreamKind.Following.contentForPost(post)?.count) == 2
                }

                it("is correct for grid mode") {
                    StreamKind.Following.setIsGridView(true)
                    expect(StreamKind.Following.contentForPost(post)?.count) == 1
                }
            }

            describe("gridPreferenceSetOffset") {

                it("is correct for all cases") {
                    let normalOffset = CGPoint(x: 0, y: -20)
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).gridPreferenceSetOffset) == CGPoint(x: 0, y: -80)
                    expect(StreamKind.Following.gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.Starred.gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.Notifications(category: "").gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.PostDetail(postParam: "param").gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.CurrentUserStream.gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.Loves(userId: "123"), title: "123").gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.Unknown.gridPreferenceSetOffset) == normalOffset
                    expect(StreamKind.UserStream(userParam: "n/a").gridPreferenceSetOffset) == normalOffset
                }
            }

            describe("isDetail") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).isDetail) == false
                    expect(StreamKind.Following.isDetail) == false
                    expect(StreamKind.Starred.isDetail) == false
                    expect(StreamKind.Notifications(category: "").isDetail) == false
                    expect(StreamKind.PostDetail(postParam: "param").isDetail) == true
                    expect(StreamKind.CurrentUserStream.isDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").isDetail) == false
                    expect(StreamKind.Unknown.isDetail) == false
                    expect(StreamKind.UserStream(userParam: "n/a").isDetail) == false
                }
            }

            describe("supportsLargeImages") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).supportsLargeImages) == false
                    expect(StreamKind.Following.supportsLargeImages) == false
                    expect(StreamKind.Starred.supportsLargeImages) == false
                    expect(StreamKind.Notifications(category: "").supportsLargeImages) == false
                    expect(StreamKind.PostDetail(postParam: "param").supportsLargeImages) == true
                    expect(StreamKind.CurrentUserStream.supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.Unknown.supportsLargeImages) == false
                    expect(StreamKind.UserStream(userParam: "n/a").supportsLargeImages) == false
                }
            }
        }
    }
}
