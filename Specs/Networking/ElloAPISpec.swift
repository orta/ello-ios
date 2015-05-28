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
                    expect(ElloAPI.Discover(type: DiscoverType.Recommended, seed: 5, perPage: 5).path) == "/api/v2/discover/users/recommended"
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
                    expect(ElloAPI.NotificationsStream.path) == "/api/v2/notifications"
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
                it("ProfileFollowing is valid") {
                    expect(ElloAPI.ProfileFollowing(priority: "anything").path) == "/api/v2/profile/following"
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
