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

            describe("name") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).name) == "Discover"
                    expect(StreamKind.Following.name) == "Friends"
                    expect(StreamKind.Starred.name) == "Noise"
                    expect(StreamKind.Notifications(category: "").name) == "Notifications"
                    expect(StreamKind.PostDetail(postParam: "param").name) == "Post Detail"
                    expect(StreamKind.Profile(perPage: 1).name) == "Profile"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").name) == "meat"
                    expect(StreamKind.Unknown.name) == "unknown"
                    expect(StreamKind.UserStream(userParam: "n/a").name) == "User Stream"
                }
            }

            describe("lastViewedCreatedAtKey") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).lastViewedCreatedAtKey) == "Discover_createdAt"
                    expect(StreamKind.Following.lastViewedCreatedAtKey) == "Friends_createdAt"
                    expect(StreamKind.Starred.lastViewedCreatedAtKey) == "Noise_createdAt"
                    expect(StreamKind.Notifications(category: "").lastViewedCreatedAtKey) == "Notifications_createdAt"
                    expect(StreamKind.PostDetail(postParam: "param").lastViewedCreatedAtKey) == "Post Detail_createdAt"
                    expect(StreamKind.Profile(perPage: 1).lastViewedCreatedAtKey) == "Profile_createdAt"
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").lastViewedCreatedAtKey) == "meat_createdAt"
                    expect(StreamKind.Unknown.lastViewedCreatedAtKey) == "unknown_createdAt"
                    expect(StreamKind.UserStream(userParam: "n/a").lastViewedCreatedAtKey) == "User Stream_createdAt"
                }
            }

            describe("columnCount") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).columnCount) == 2
                    expect(StreamKind.Following.columnCount) == 1
                    expect(StreamKind.Starred.columnCount) == 2
                    expect(StreamKind.Notifications(category: "").columnCount) == 1
                    expect(StreamKind.PostDetail(postParam: "param").columnCount) == 1
                    expect(StreamKind.Profile(perPage: 1).columnCount) == 1
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").columnCount) == 2
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").columnCount) == 1
                    expect(StreamKind.Unknown.columnCount) == 1
                    expect(StreamKind.UserStream(userParam: "n/a").columnCount) == 1
                }
            }

            describe("tappingTextOpensDetail") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).tappingTextOpensDetail) == true
                    expect(StreamKind.Following.tappingTextOpensDetail) == false
                    expect(StreamKind.Starred.tappingTextOpensDetail) == true
                    expect(StreamKind.Notifications(category: "").tappingTextOpensDetail) == true
                    expect(StreamKind.PostDetail(postParam: "param").tappingTextOpensDetail) == false
                    expect(StreamKind.Profile(perPage: 1).tappingTextOpensDetail) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").tappingTextOpensDetail) == true
                    expect(StreamKind.Unknown.tappingTextOpensDetail) == true
                    expect(StreamKind.UserStream(userParam: "n/a").tappingTextOpensDetail) == false
                }
            }

            describe("endpoint") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).endpoint.path) == "/api/\(ElloAPI.apiVersion)/discover/users/\(DiscoverType.Recommended.rawValue)"
                    expect(StreamKind.Following.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/friend"
                    expect(StreamKind.Starred.endpoint.path) == "/api/\(ElloAPI.apiVersion)/streams/noise"
                    expect(StreamKind.Notifications(category: "").endpoint.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.PostDetail(postParam: "param").endpoint.path) == "/api/\(ElloAPI.apiVersion)/posts/param"
                    expect(StreamKind.Profile(perPage: 1).endpoint.path) == "/api/\(ElloAPI.apiVersion)/profile"
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
                    expect(StreamKind.Profile(perPage: 1).relationship) == RelationshipPriority.Null
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").relationship) == RelationshipPriority.Null
                    expect(StreamKind.Unknown.relationship) == RelationshipPriority.Null
                    expect(StreamKind.UserStream(userParam: "n/a").relationship) == RelationshipPriority.Null
                }
            }

            xdescribe("filter(_:viewsAdultContent:)") {
                // important but time consuming to implement this one, little by little!
            }

            describe("showStarredButton") {

                let tests: [(Bool, StreamKind)] = [
                    (true, StreamKind.Discover(type: .Recommended, perPage: 1)),
                    (true, StreamKind.Following),
                    (true, StreamKind.Starred),
                    (true, StreamKind.Notifications(category: "")),
                    (true, StreamKind.PostDetail(postParam: "param")),
                    (true, StreamKind.Profile(perPage: 1)),
                    (true, StreamKind.Unknown),
                    (true, StreamKind.UserStream(userParam: "n/a")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat")),
                    (true, StreamKind.SimpleStream(endpoint: ElloAPI.UserStreamFollowers(userId: "12345"), title: "")),
                    (false, StreamKind.SimpleStream(endpoint: ElloAPI.AwesomePeopleStream, title: "")),
                    (false, StreamKind.SimpleStream(endpoint: ElloAPI.CommunitiesStream, title: "")),
                    (false, StreamKind.SimpleStream(endpoint: ElloAPI.FoundersStream, title: "")),
                ]
                for (shouldStar, streamKind) in tests {
                    it("is \(shouldStar) for \(streamKind)") {
                        expect(streamKind.showStarredButton) == shouldStar
                    }
                }
            }

            describe("isGridLayout") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).isGridLayout) == true
                    expect(StreamKind.Following.isGridLayout) == false
                    expect(StreamKind.Starred.isGridLayout) == true
                    expect(StreamKind.Notifications(category: "").isGridLayout) == false
                    expect(StreamKind.PostDetail(postParam: "param").isGridLayout) == false
                    expect(StreamKind.Profile(perPage: 1).isGridLayout) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").isGridLayout) == true
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").isGridLayout) == false
                    expect(StreamKind.Unknown.isGridLayout) == false
                    expect(StreamKind.UserStream(userParam: "n/a").isGridLayout) == false
                }
            }

            describe("isDetail") {

                it("is correct for all cases") {
                    expect(StreamKind.Discover(type: .Recommended, perPage: 1).isDetail) == false
                    expect(StreamKind.Following.isDetail) == false
                    expect(StreamKind.Starred.isDetail) == false
                    expect(StreamKind.Notifications(category: "").isDetail) == false
                    expect(StreamKind.PostDetail(postParam: "param").isDetail) == true
                    expect(StreamKind.Profile(perPage: 1).isDetail) == false
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
                    expect(StreamKind.Profile(perPage: 1).supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForPosts(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.SimpleStream(endpoint: ElloAPI.SearchForUsers(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.Unknown.supportsLargeImages) == false
                    expect(StreamKind.UserStream(userParam: "n/a").supportsLargeImages) == false
                }
            }
        }
    }
}
