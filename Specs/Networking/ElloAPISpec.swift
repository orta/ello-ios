//
//  ElloAPISpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Ello
import Quick
import Moya
import Nimble


class ElloAPISpec: QuickSpec {
    override func spec() {

        var provider: MoyaProvider<ElloAPI>!

        beforeEach {
            provider = ElloProvider.StubbingProvider()
        }

        afterEach {
            provider = ElloProvider.DefaultProvider()
        }

        describe("ElloAPI") {
            describe("paths") {

                context("are valid") {
                    it("AmazonCredentials is valid") {
                        expect(ElloAPI.AmazonCredentials.path) ==  "/api/v2/assets/credentials"
                    }
                    it("Auth is valid") {
                        expect(ElloAPI.Auth(email: "", password: "").path) == "/api/oauth/token"
                    }
                    it("Availability is valid") {
                        expect(ElloAPI.Availability(content: [:]).path) == "/api/v2/availability"
                    }
                    it("AwesomePeopleStream is valid") {
                        expect(ElloAPI.AwesomePeopleStream.path) == "/api/v2/discover/users/recommended"
                    }
                    it("CommunitiesStream is valid") {
                        expect(ElloAPI.CommunitiesStream.path) == "/api/v2/interest_categories/members"
                    }
                    xit("FoundersStream is valid") {
                        expect(ElloAPI.FoundersStream.path) == "/api/v2/not-implemented-yet!"
                    }
                    it("CreatePost is valid") {
                        expect(ElloAPI.CreatePost(body: [:]).path) == "/api/v2/posts"
                    }
                    it("Discover is valid") {
                        expect(ElloAPI.Discover(type: DiscoverType.Recommended, perPage: 5).path) == "/api/v2/discover/users/recommended"
                    }
                    it("FlagComment is valid") {
                        expect(ElloAPI.FlagComment(postId: "555", commentId: "666", kind: "some-string").path) == "/api/v2/posts/555/comments/666/flag/some-string"
                    }
                    it("FlagPost is valid") {
                        expect(ElloAPI.FlagPost(postId: "456", kind: "another-kind").path) == "/api/v2/posts/456/flag/another-kind"
                    }
                    it("FindFriends is valid") {
                        expect(ElloAPI.FindFriends(contacts: [:]).path) == "/api/v2/profile/find_friends"
                    }
                    it("FriendStream is valid") {
                        expect(ElloAPI.FriendStream.path) == "/api/v2/streams/friend"
                    }
                    it("InfiniteScroll is valid") {
                        let infiniteScrollEndpoint = ElloAPI.InfiniteScroll(queryItems: []) { return ElloAPI.FriendStream }
                        expect(infiniteScrollEndpoint.path) == "/api/v2/streams/friend"
                    }
                    it("InviteFriends is valid") {
                        expect(ElloAPI.InviteFriends(contact: "someContact").path) == "/api/v2/invitations"
                    }
                    it("NoiseStream is valid") {
                        expect(ElloAPI.NoiseStream.path) == "/api/v2/streams/noise"
                    }
                    it("NotificationsStream is valid") {
                        expect(ElloAPI.NotificationsStream(category: nil).path) == "/api/v2/notifications"
                    }
                    it("PostDetail is valid") {
                        expect(ElloAPI.PostDetail(postParam: "some-param").path) == "/api/v2/posts/some-param"
                    }
                    it("PostComments is valid") {
                        expect(ElloAPI.PostComments(postId: "fake-id").path) == "/api/v2/posts/fake-id/comments"
                    }
                    it("Profile is valid") {
                        expect(ElloAPI.Profile(perPage: 10).path) == "/api/v2/profile"
                    }
                    it("ProfileUpdate is valid") {
                        expect(ElloAPI.ProfileUpdate(body: [:]).path) == "/api/v2/profile"
                    }
                    it("ProfileDelete is valid") {
                        expect(ElloAPI.ProfileDelete.path) == "/api/v2/profile"
                    }
                    it("ReAuth is valid") {
                        expect(ElloAPI.ReAuth.path) == "/api/oauth/token"
                    }
                    it("Relationship is valid") {
                        expect(ElloAPI.Relationship(userId: "1234", relationship: "friend").path) == "/api/v2/users/1234/add/friend"
                    }
                    it("UserStream is valid") {
                        expect(ElloAPI.UserStream(userParam: "999").path) == "/api/v2/users/999"
                    }
                    it("UserStreamFollowers is valid") {
                        expect(ElloAPI.UserStreamFollowers(userId: "321").path) == "/api/v2/users/321/followers"
                    }
                    it("UserStreamFollowing is valid") {
                        expect(ElloAPI.UserStreamFollowing(userId: "123").path) == "/api/v2/users/123/following"
                    }
                    it("DeletePost is valid") {
                        expect(ElloAPI.DeletePost(postId: "666").path) == "/api/v2/posts/666"
                    }
                    it("DeleteComment is valid") {
                        expect(ElloAPI.DeleteComment(postId: "666", commentId: "777").path) == "/api/v2/posts/666/comments/777"
                    }
                }
            }

            describe("headers") {

                context("no authorization required") {

                    it("has the correct headers") {

                        let endpoints = [
                            ElloAPI.AnonymousCredentials,
                            ElloAPI.Auth(email: "", password: ""),
                            ElloAPI.ReAuth
                        ]

                        for endpoint in endpoints {
                            expect(endpoint.headers).to(beEmpty())
                        }
                    }
                }

                context("If-Modified-Since endpoints") {

                    it("has the correct headers") {

                        let date = NSDate()

                        let endpoints = [
                            ElloAPI.FriendNewContent(createdAt: date),
                            ElloAPI.NoiseNewContent(createdAt: date),
                            ElloAPI.NotificationsNewContent(createdAt: date)
                        ]

                        for endpoint in endpoints {
                            expect(endpoint.headers["Content-Type"] as? String) == "application/json"
                            expect(endpoint.headers["Authorization"] as? String) == AuthToken().tokenWithBearer ?? ""
                            expect(endpoint.headers["Accept-Language"] as? String) == ""
                            expect(endpoint.headers["If-Modified-Since"] as? String) == date.toHTTPDateString()
                        }
                    }
                }

                context("normal authorization required") {

                    it("has the correct headers") {

                        let endpoints = [
                            ElloAPI.AmazonCredentials,
                            ElloAPI.Availability(content: [:]),
                            ElloAPI.AwesomePeopleStream,
                            ElloAPI.CommunitiesStream,
                            ElloAPI.CreateComment(parentPostId: "", body: [:]),
                            ElloAPI.CreateLove(postId: ""),
                            ElloAPI.CreatePost(body: [:]),
                            ElloAPI.DeleteComment(postId: "", commentId: ""),
                            ElloAPI.DeleteLove(postId: ""),
                            ElloAPI.DeletePost(postId: ""),
                            ElloAPI.DeleteSubscriptions(token: NSData()),
                            ElloAPI.Discover(type: DiscoverType.Random, perPage: 0),
                            ElloAPI.EmojiAutoComplete(terms: ""),
                            ElloAPI.FindFriends(contacts: ["" : [""]]),
                            ElloAPI.FlagComment(postId: "", commentId: "", kind: ""),
                            ElloAPI.FlagPost(postId: "", kind: ""),
                            ElloAPI.FoundersStream,
                            ElloAPI.FriendStream,
                            ElloAPI.InfiniteScroll(queryItems: [""], elloApi: { () -> ElloAPI in
                                return ElloAPI.FriendStream
                            }),
                            ElloAPI.InviteFriends(contact: ""),
                            ElloAPI.Join(email: "", username: "", password: "", invitationCode: ""),
                            ElloAPI.Loves(userId: ""),
                            ElloAPI.NoiseStream,
                            ElloAPI.NotificationsStream(category: ""),
                            ElloAPI.PostComments(postId: ""),
                            ElloAPI.PostDetail(postParam: ""),
                            ElloAPI.PostLovers(postId: ""),
                            ElloAPI.PostReposters(postId: ""),
                            ElloAPI.Profile(perPage: 0),
                            ElloAPI.ProfileDelete,
                            ElloAPI.ProfileToggles,
                            ElloAPI.ProfileUpdate(body: [:]),
                            ElloAPI.RePost(postId: ""),
                            ElloAPI.PushSubscriptions(token: NSData()),
                            ElloAPI.Relationship(userId: "", relationship: ""),
                            ElloAPI.RelationshipBatch(userIds: [""], relationship: ""),
                            ElloAPI.SearchForUsers(terms: ""),
                            ElloAPI.SearchForPosts(terms: ""),
                            ElloAPI.UserStream(userParam: ""),
                            ElloAPI.UserStreamFollowers(userId: ""),
                            ElloAPI.UserStreamFollowing(userId: ""),
                            ElloAPI.UserNameAutoComplete(terms: "")
                        ]

                        for endpoint in endpoints {
                            expect(endpoint.headers["Content-Type"] as? String) == "application/json"
                            expect(endpoint.headers["Authorization"] as? String) == AuthToken().tokenWithBearer ?? ""
                            expect(endpoint.headers["Accept-Language"] as? String) == ""
                        }
                    }
                }
            }

            describe("encoding") {

                context("Moya.ParameterEncoding.JSON endpoints") {

                    it("returns .JSON") {
                        let endpoints = [
                            ElloAPI.CreatePost(body: [:]),
                            ElloAPI.CreateComment(parentPostId: "", body: [:]),
                            ElloAPI.ProfileUpdate(body: [:]),
                            ElloAPI.RePost(postId: ""),
                            ElloAPI.FindFriends(contacts: [:])
                        ]

                        for endpoint in endpoints {
                            expect(endpoint.encoding) == Moya.ParameterEncoding.JSON
                        }
                    }
                }

                context("Moya.ParameterEncoding.URL endpoints") {

                    it("returns .URL") {
                        let endpoints = [
                            ElloAPI.AmazonCredentials,
                            ElloAPI.AnonymousCredentials,
                            ElloAPI.Auth(email: "", password: ""),
                            ElloAPI.Availability(content: [:]),
                            ElloAPI.AwesomePeopleStream,
                            ElloAPI.CommunitiesStream,
                            ElloAPI.CreateLove(postId: ""),
                            ElloAPI.DeleteComment(postId: "", commentId: ""),
                            ElloAPI.DeleteLove(postId: ""),
                            ElloAPI.DeletePost(postId: ""),
                            ElloAPI.DeleteSubscriptions(token: NSData()),
                            ElloAPI.Discover(type: DiscoverType.Random, perPage: 0),
                            ElloAPI.EmojiAutoComplete(terms: ""),
                            ElloAPI.FlagComment(postId: "", commentId: "", kind: ""),
                            ElloAPI.FlagPost(postId: "", kind: ""),
                            ElloAPI.FoundersStream,
                            ElloAPI.FriendStream,
                            ElloAPI.FriendNewContent(createdAt: NSDate()),
                            ElloAPI.InfiniteScroll(queryItems: [""], elloApi: { () -> ElloAPI in
                                return ElloAPI.FriendStream
                            }),
                            ElloAPI.InviteFriends(contact: ""),
                            ElloAPI.Join(email: "", username: "", password: "", invitationCode: ""),
                            ElloAPI.Loves(userId: ""),
                            ElloAPI.NoiseStream,
                            ElloAPI.NoiseNewContent(createdAt: NSDate()),
                            ElloAPI.NotificationsNewContent(createdAt: NSDate()),
                            ElloAPI.NotificationsStream(category: ""),
                            ElloAPI.PostComments(postId: ""),
                            ElloAPI.PostDetail(postParam: ""),
                            ElloAPI.PostLovers(postId: ""),
                            ElloAPI.PostReposters(postId: ""),
                            ElloAPI.Profile(perPage: 0),
                            ElloAPI.ProfileDelete,
                            ElloAPI.ProfileToggles,
                            ElloAPI.PushSubscriptions(token: NSData()),
                            ElloAPI.ReAuth,
                            ElloAPI.Relationship(userId: "", relationship: ""),
                            ElloAPI.RelationshipBatch(userIds: [""], relationship: ""),
                            ElloAPI.SearchForUsers(terms: ""),
                            ElloAPI.SearchForPosts(terms: ""),
                            ElloAPI.UserStream(userParam: ""),
                            ElloAPI.UserStreamFollowers(userId: ""),
                            ElloAPI.UserStreamFollowing(userId: ""),
                            ElloAPI.UserNameAutoComplete(terms: "")
                        ]

                        for endpoint in endpoints {
                            expect(endpoint.encoding) == Moya.ParameterEncoding.URL
                        }
                    }
                }
            }

            describe("parameter values") {

                it("AnonymousCredentials") {
                    let params = ElloAPI.AnonymousCredentials.parameters
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "client_credentials"
                }

                it("Auth") {
                    let params = ElloAPI.Auth(email: "me@me.me", password: "p455w0rd").parameters
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["email"] as? String) == "me@me.me"
                    expect(params["password"] as? String) == "p455w0rd"
                    expect(params["grant_type"] as? String) == "password"
                }

                it("Availability") {
                    let content = ["username": "sterlingarcher"]
                    expect(ElloAPI.Availability(content: content).parameters as? [String: String]) == content
                }

                it("AwesomePeopleStream") {
                    let params = ElloAPI.AwesomePeopleStream.parameters
                    expect(params["per_page"] as? Int) == 25
                    expect(params["seed"]).notTo(beNil())
                }

                it("CommunitiesStream") {
                    let params = ElloAPI.CommunitiesStream.parameters
                    expect(params["name"] as? String) == "onboarding"
                    expect(params["per_page"] as? Int) == 25
                }

                it("CreateComment") {
                    let content = ["text": "my sweet comment content"]
                    expect(ElloAPI.CreateComment(parentPostId: "id", body: content).parameters as? [String: String]) == content
                }

                it("CreatePost") {
                    let content = ["text": "my sweet post content"]
                    expect(ElloAPI.CreatePost(body: content).parameters as? [String: String]) == content
                }

                it("Discover") {
                    let params = ElloAPI.Discover(type: .Recommended, perPage: 10).parameters
                    expect(params["per_page"] as? Int) == 10
                    expect(params["include_recent_posts"] as? Bool) == true
                    expect(params["seed"]).notTo(beNil())
                }

                xit("FindFriends") {

                }

                it("FriendStream") {
                    let params = ElloAPI.FriendStream.parameters
                    expect(params["per_page"] as? Int) == 10
                }

                it("InfiniteScroll") {
                    let queryItems = NSURLComponents(string: "ttp://ello.co/api/v2/posts/278/comments?after=2014-06-02T00%3A00%3A00.000000000%2B0000&per_page=2")!.queryItems
                    let infiniteScroll = ElloAPI.InfiniteScroll(queryItems: queryItems!) { return ElloAPI.Discover(type: .Recommended, perPage: 10) }
                    let params = infiniteScroll.parameters
                    expect(params["per_page"] as? String) == "2"
                    expect(params["include_recent_posts"] as? Bool) == true
                    expect(params["seed"]).notTo(beNil())
                    expect(params["after"]).notTo(beNil())
                }

                it("InviteFriends") {
                    let params = ElloAPI.InviteFriends(contact: "me@me.me").parameters
                    expect(params["email"] as? String) == "me@me.me"
                }

                it("Join") {
                    context("without an invitation code") {
                        let params = ElloAPI.Join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: nil).parameters
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"]).to(beNil())
                    }

                    context("with an invitation code") {
                        let params = ElloAPI.Join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: "my-sweet-code").parameters
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"] as? String) == "my-sweet-code"
                    }
                }

                it("NoiseStream") {
                    let params = ElloAPI.NoiseStream.parameters
                    expect(params["per_page"] as? Int) == 10
                }

                describe("NotificationsStream") {

                    context("without a category") {
                        let params = ElloAPI.NotificationsStream(category: nil).parameters
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"]).to(beNil())
                    }

                    context("with a category") {
                        let params = ElloAPI.NotificationsStream(category: "all").parameters
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"] as? String) == "all"
                    }
                }

                it("PostComments") {
                    let params = ElloAPI.PostComments(postId: "comments-id").parameters
                    expect(params["per_page"] as? Int) == 10
                }

                it("Profile") {
                    let params = ElloAPI.Profile(perPage: 42).parameters
                    expect(params["post_count"] as? Int) == 42
                }

                xit("PushSubscriptions, DeleteSubscriptions") {

                }

                it("ReAuth") {
                    let params = ElloAPI.ReAuth.parameters
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "refresh_token"
                    expect(params["refresh_token"]).notTo(beNil())
                }

                it("RelationshipBatch") {
                    let params = ElloAPI.RelationshipBatch(userIds: ["1", "2", "8"], relationship: "friend").parameters
                    expect(params["user_ids"] as? [String]) == ["1", "2", "8"]
                    expect(params["priority"] as? String) == "friend"
                }

                it("RePost") {
                    let params = ElloAPI.RePost(postId: "666").parameters
                    expect(params["repost_id"] as? Int) == 666
                }

                it("SearchForPosts") {
                    let params = ElloAPI.SearchForPosts(terms: "blah").parameters
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("SearchForUsers") {
                    let params = ElloAPI.SearchForUsers(terms: "blah").parameters
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("UserNameAutoComplete") {
                    let params = ElloAPI.UserNameAutoComplete(terms: "blah").parameters
                    expect(params["terms"] as? String) == "blah"
                }
            }

            describe("valid enpoints") {
                describe("with stubbed responses") {
                    describe("a provider") {
                        it("returns stubbed data for auth request") {
                            var message: String?

                            let target: ElloAPI = .Auth(email:"test@example.com", password: "123456")
                            provider.request(target, completion: { (data, statusCode, response, error) in
                                if let data = data {
                                    message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                                }
                            })

                            let sampleData = target.sampleData as NSData
                            expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                        }

                        it("returns stubbed data for friends stream request") {
                            var message: String?

                            let target: ElloAPI = .FriendStream
                            provider.request(target, completion: { (data, statusCode, response, error) in
                                if let data = data {
                                    message = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                                }
                            })
                            
                            let sampleData = target.sampleData as NSData
                            expect(message).to(equal(NSString(data: sampleData, encoding: NSUTF8StringEncoding)))
                        }
                    }
                }
            }
        }
    }
}
