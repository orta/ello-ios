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

            it("are valid") {
                expect(ElloAPI.AmazonCredentials.path) ==  "/api/edge/assets/credentials"
                expect(ElloAPI.Auth(email: "", password: "").path) == "/api/oauth/token"
                expect(ElloAPI.Availability(content: [:]).path) == "/api/edge/availability"
                expect(ElloAPI.CreatePost(body: [:]).path) == "/api/edge/posts"
                expect(ElloAPI.Discover(type: DiscoverType.Recommended, seed: 5, perPage: 5).path) == "/api/edge/discover/users/recommended"
                expect(ElloAPI.FlagComment(postId: "555", commentId: "666", kind: "some-string").path) == "/api/edge/posts/555/comments/666/flag/some-string"
                expect(ElloAPI.FlagPost(postId: "456", kind: "another-kind").path) == "/api/edge/posts/456/flag/another-kind"
                expect(ElloAPI.FindFriends(contacts: [:]).path) == "/api/edge/profile/find_friends"
                expect(ElloAPI.FriendStream.path) == "/api/edge/streams/friend"
                let infiniteScrollEndpoint = ElloAPI.InfiniteScroll(queryItems: []) { return ElloAPI.FriendStream }
                expect(infiniteScrollEndpoint.path) == "/api/edge/streams/friend"
                expect(ElloAPI.InviteFriends(contact: "someContact").path) == "/api/edge/invitations"
                expect(ElloAPI.NoiseStream.path) == "/api/edge/streams/noise"
                expect(ElloAPI.NotificationsStream.path) == "/api/edge/notifications"
                expect(ElloAPI.PostDetail(postParam: "some-param").path) == "/api/edge/posts/some-param"
                expect(ElloAPI.PostComments(postId: "fake-id").path) == "/api/edge/posts/fake-id/comments"
                expect(ElloAPI.Profile(perPage: 10).path) == "/api/edge/profile"
                expect(ElloAPI.ProfileUpdate(body: [:]).path) == "/api/edge/profile"
                expect(ElloAPI.ProfileDelete.path) == "/api/edge/profile"
                expect(ElloAPI.ProfileFollowing(priority: "anything").path) == "/api/edge/profile/following"
                expect(ElloAPI.ReAuth.path) == "/api/oauth/token"
                expect(ElloAPI.Relationship(userId: "1234", relationship: "friend").path) == "/api/edge/users/1234/add/friend"
                expect(ElloAPI.UserStream(userParam: "999").path) == "/api/edge/users/999"
                expect(ElloAPI.UserStreamFollowers(userId: "321").path) == "/api/edge/users/321/followers"
                expect(ElloAPI.UserStreamFollowing(userId: "123").path) == "/api/edge/users/123/following"
                expect(ElloAPI.DeletePost(postId: "666").path) == "/api/edge/posts/666"
                expect(ElloAPI.DeleteComment(postId: "666", commentId: "777").path) == "/api/edge/posts/666/comments/777"
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
