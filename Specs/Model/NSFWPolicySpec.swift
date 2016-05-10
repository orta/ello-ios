//
//  NSFWPolicySpec.swift
//  Ello
//
//  Created by Sean on 5/5/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class NSFWPolicySpec: QuickSpec {
    override func spec() {

        let alwaysViewNSFW = [
            "CurrentUserStream",
            "CurrentUserProfile",
            "NotificationsStream",
            "NotificationsNewContent",
            "EditProfile",
            "Invitations",
            "UserNameAutoComplete",
            "UserStreamFollowers",
            "UserStreamFollowing"
        ]

        let loggedInViewsNSFW = [
            "FriendNewContent",
            "FriendStream",
            "NoiseNewContent",
            "NoiseStream",
            "PostDetail",
            "UserStream"
        ]

        let currentUserViewsOwnNSFW = true

        let subject = NSFWPolicy(
            alwaysViewNSFW: alwaysViewNSFW,
            loggedInViewsNSFW: loggedInViewsNSFW,
            currentUserViewsOwnNSFW: currentUserViewsOwnNSFW
        )

        describe("NSFWPolicy") {
            describe("includeNSFW(_:)") {
                context("current user DOES view nsfw") {
                    let currentUserId = "123"
                    let currentUser: User = stub(["id" : currentUserId, "username": "TestName", "viewsAdultContent": true, "profile": Profile.stub(["email": "some@guy.com"])])
                    let expectations = [
                    (ElloAPI.AmazonCredentials, false),
                    (ElloAPI.AnonymousCredentials, false),
                    (ElloAPI.Auth(email: "", password: ""), false),
                    (ElloAPI.Availability(content: ["":""]), false),
                    (ElloAPI.AwesomePeopleStream, false),
                    (ElloAPI.CommentDetail(postId: "", commentId: ""), false),
                    (ElloAPI.CommunitiesStream, false),
                    (ElloAPI.CreateComment(parentPostId: "", body: ["": ""]), false),
                    (ElloAPI.CreateLove(postId: ""), false),
                    (ElloAPI.CreatePost(body: ["": ""]), false),
                    (ElloAPI.CurrentUserProfile, true),
                    (ElloAPI.CurrentUserStream, true),
                    (ElloAPI.DeleteComment(postId: "", commentId: ""), false),
                    (ElloAPI.DeleteLove(postId: ""), false),
                    (ElloAPI.DeletePost(postId: ""), false),
                    (ElloAPI.DeleteSubscriptions(token: NSData()), false),
                    (ElloAPI.Discover(type: .Recommended, perPage: 0), false),
                    (ElloAPI.Discover(type: .Trending, perPage: 0), false),
                    (ElloAPI.Discover(type: .Recent, perPage: 0), false),
                    (ElloAPI.EmojiAutoComplete(terms: ""), false),
                    (ElloAPI.FindFriends(contacts: ["": [""]]), false),
                    (ElloAPI.FlagComment(postId: "", commentId: "", kind: ""), false),
                    (ElloAPI.FlagPost(postId: "", kind: ""), false),
                    (ElloAPI.FriendStream, true),
                    (ElloAPI.FriendNewContent(createdAt: NSDate()), true),
                    (ElloAPI.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                    (ElloAPI.InviteFriends(contact: ""), false),
                    (ElloAPI.Join(email: "", username: "", password: "", invitationCode: ""), false),
                    (ElloAPI.Loves(userId: ""), false),
                    (ElloAPI.Loves(userId: currentUserId), true),
                    (ElloAPI.NoiseStream, true),
                    (ElloAPI.NoiseNewContent(createdAt: NSDate()), true),
                    (ElloAPI.NotificationsNewContent(createdAt: NSDate()), true),
                    (ElloAPI.NotificationsStream(category: ""), true),
                    (ElloAPI.PostComments(postId: ""), false),
                    (ElloAPI.PostDetail(postParam: "", commentCount: 0), true),
                    (ElloAPI.PostLovers(postId: ""), false),
                    (ElloAPI.PostReposters(postId: ""), false),
                    (ElloAPI.ProfileDelete, false),
                    (ElloAPI.ProfileToggles, false),
                    (ElloAPI.ProfileUpdate(body: ["": ""]), false),
                    (ElloAPI.PushSubscriptions(token: NSData()), false),
                    (ElloAPI.ReAuth(token: ""), false),
                    (ElloAPI.RePost(postId: ""), false),
                    (ElloAPI.Relationship(userId: "", relationship: ""), false),
                    (ElloAPI.RelationshipBatch(userIds: [""], relationship: ""), false),
                    (ElloAPI.SearchForUsers(terms: ""), false),
                    (ElloAPI.SearchForPosts(terms: ""), false),
                    (ElloAPI.UpdatePost(postId: "", body: ["": ""]), false),
                    (ElloAPI.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                    (ElloAPI.UserStream(userParam: ""), true),
                    (ElloAPI.UserStream(userParam: currentUserId), true),
                    (ElloAPI.UserStreamFollowers(userId: ""), true),
                    (ElloAPI.UserStreamFollowing(userId: ""), true),
                    (ElloAPI.UserNameAutoComplete(terms: ""), true)
                    ]
                    for (endpoint, showsNSFW) in expectations {
                        it("\(endpoint) is \(showsNSFW)") {
                            expect(subject.includeNSFW(endpoint, currentUser: currentUser)) == showsNSFW
                        }
                    }
                }

                context("current user DOES NOT view nsfw") {
                    let currentUserId = "123"
                    let currentUser: User = stub(["id" : currentUserId, "username": "TestName", "viewsAdultContent": false, "profile": Profile.stub(["email": "some@guy.com"])])

                    let expectations = [
                        (ElloAPI.AmazonCredentials, false),
                        (ElloAPI.AnonymousCredentials, false),
                        (ElloAPI.Auth(email: "", password: ""), false),
                        (ElloAPI.Availability(content: ["":""]), false),
                        (ElloAPI.AwesomePeopleStream, false),
                        (ElloAPI.CommentDetail(postId: "", commentId: ""), false),
                        (ElloAPI.CommunitiesStream, false),
                        (ElloAPI.CreateComment(parentPostId: "", body: ["": ""]), false),
                        (ElloAPI.CreateLove(postId: ""), false),
                        (ElloAPI.CreatePost(body: ["": ""]), false),
                        (ElloAPI.CurrentUserProfile, true),
                        (ElloAPI.CurrentUserStream, true),
                        (ElloAPI.DeleteComment(postId: "", commentId: ""), false),
                        (ElloAPI.DeleteLove(postId: ""), false),
                        (ElloAPI.DeletePost(postId: ""), false),
                        (ElloAPI.DeleteSubscriptions(token: NSData()), false),
                        (ElloAPI.Discover(type: .Recommended, perPage: 0), false),
                        (ElloAPI.Discover(type: .Trending, perPage: 0), false),
                        (ElloAPI.Discover(type: .Recent, perPage: 0), false),
                        (ElloAPI.EmojiAutoComplete(terms: ""), false),
                        (ElloAPI.FindFriends(contacts: ["": [""]]), false),
                        (ElloAPI.FlagComment(postId: "", commentId: "", kind: ""), false),
                        (ElloAPI.FlagPost(postId: "", kind: ""), false),
                        (ElloAPI.FriendStream, false),
                        (ElloAPI.FriendNewContent(createdAt: NSDate()), false),
                        (ElloAPI.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                        (ElloAPI.InviteFriends(contact: ""), false),
                        (ElloAPI.Join(email: "", username: "", password: "", invitationCode: ""), false),
                        (ElloAPI.Loves(userId: ""), false),
                        (ElloAPI.Loves(userId: currentUserId), true),
                        (ElloAPI.NoiseStream, false),
                        (ElloAPI.NoiseNewContent(createdAt: NSDate()), false),
                        (ElloAPI.NotificationsNewContent(createdAt: NSDate()), true),
                        (ElloAPI.NotificationsStream(category: ""), true),
                        (ElloAPI.PostComments(postId: ""), false),
                        (ElloAPI.PostDetail(postParam: "", commentCount: 0), false),
                        (ElloAPI.PostLovers(postId: ""), false),
                        (ElloAPI.PostReposters(postId: ""), false),
                        (ElloAPI.ProfileDelete, false),
                        (ElloAPI.ProfileToggles, false),
                        (ElloAPI.ProfileUpdate(body: ["": ""]), false),
                        (ElloAPI.PushSubscriptions(token: NSData()), false),
                        (ElloAPI.ReAuth(token: ""), false),
                        (ElloAPI.RePost(postId: ""), false),
                        (ElloAPI.Relationship(userId: "", relationship: ""), false),
                        (ElloAPI.RelationshipBatch(userIds: [""], relationship: ""), false),
                        (ElloAPI.SearchForUsers(terms: ""), false),
                        (ElloAPI.SearchForPosts(terms: ""), false),
                        (ElloAPI.UpdatePost(postId: "", body: ["": ""]), false),
                        (ElloAPI.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                        (ElloAPI.UserStream(userParam: ""), false),
                        (ElloAPI.UserStream(userParam: currentUserId), true),
                        (ElloAPI.UserStreamFollowers(userId: ""), true),
                        (ElloAPI.UserStreamFollowers(userId: currentUserId), true),
                        (ElloAPI.UserStreamFollowing(userId: ""), true),
                        (ElloAPI.UserStreamFollowing(userId: currentUserId), true),
                        (ElloAPI.UserNameAutoComplete(terms: ""), true)
                    ]
                    for (endpoint, showsNSFW) in expectations {
                        it("\(endpoint) is \(showsNSFW)") {
                            expect(subject.includeNSFW(endpoint, currentUser: currentUser)) == showsNSFW
                        }
                    }
                }

                context("current user DOES NOT view nsfw and we don't let them view themselves in streams if they are nsfw") {

                    let subject = NSFWPolicy(
                        alwaysViewNSFW: alwaysViewNSFW,
                        loggedInViewsNSFW: loggedInViewsNSFW,
                        currentUserViewsOwnNSFW: false
                    )

                    let currentUserId = "123"
                    let currentUser: User = stub(["id" : currentUserId, "username": "TestName", "viewsAdultContent": false, "profile": Profile.stub(["email": "some@guy.com"])])

                    let expectations = [
                        (ElloAPI.AmazonCredentials, false),
                        (ElloAPI.AnonymousCredentials, false),
                        (ElloAPI.Auth(email: "", password: ""), false),
                        (ElloAPI.Availability(content: ["":""]), false),
                        (ElloAPI.AwesomePeopleStream, false),
                        (ElloAPI.CommentDetail(postId: "", commentId: ""), false),
                        (ElloAPI.CommunitiesStream, false),
                        (ElloAPI.CreateComment(parentPostId: "", body: ["": ""]), false),
                        (ElloAPI.CreateLove(postId: ""), false),
                        (ElloAPI.CreatePost(body: ["": ""]), false),
                        (ElloAPI.CurrentUserProfile, true),
                        (ElloAPI.CurrentUserStream, true),
                        (ElloAPI.DeleteComment(postId: "", commentId: ""), false),
                        (ElloAPI.DeleteLove(postId: ""), false),
                        (ElloAPI.DeletePost(postId: ""), false),
                        (ElloAPI.DeleteSubscriptions(token: NSData()), false),
                        (ElloAPI.Discover(type: .Recommended, perPage: 0), false),
                        (ElloAPI.Discover(type: .Trending, perPage: 0), false),
                        (ElloAPI.Discover(type: .Recent, perPage: 0), false),
                        (ElloAPI.EmojiAutoComplete(terms: ""), false),
                        (ElloAPI.FindFriends(contacts: ["": [""]]), false),
                        (ElloAPI.FlagComment(postId: "", commentId: "", kind: ""), false),
                        (ElloAPI.FlagPost(postId: "", kind: ""), false),
                        (ElloAPI.FriendStream, false),
                        (ElloAPI.FriendNewContent(createdAt: NSDate()), false),
                        (ElloAPI.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                        (ElloAPI.InviteFriends(contact: ""), false),
                        (ElloAPI.Join(email: "", username: "", password: "", invitationCode: ""), false),
                        (ElloAPI.Loves(userId: ""), false),
                        (ElloAPI.Loves(userId: currentUserId), false),
                        (ElloAPI.NoiseStream, false),
                        (ElloAPI.NoiseNewContent(createdAt: NSDate()), false),
                        (ElloAPI.NotificationsNewContent(createdAt: NSDate()), true),
                        (ElloAPI.NotificationsStream(category: ""), true),
                        (ElloAPI.PostComments(postId: ""), false),
                        (ElloAPI.PostDetail(postParam: "", commentCount: 0), false),
                        (ElloAPI.PostLovers(postId: ""), false),
                        (ElloAPI.PostReposters(postId: ""), false),
                        (ElloAPI.ProfileDelete, false),
                        (ElloAPI.ProfileToggles, false),
                        (ElloAPI.ProfileUpdate(body: ["": ""]), false),
                        (ElloAPI.PushSubscriptions(token: NSData()), false),
                        (ElloAPI.ReAuth(token: ""), false),
                        (ElloAPI.RePost(postId: ""), false),
                        (ElloAPI.Relationship(userId: "", relationship: ""), false),
                        (ElloAPI.RelationshipBatch(userIds: [""], relationship: ""), false),
                        (ElloAPI.SearchForUsers(terms: ""), false),
                        (ElloAPI.SearchForPosts(terms: ""), false),
                        (ElloAPI.UpdatePost(postId: "", body: ["": ""]), false),
                        (ElloAPI.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                        (ElloAPI.UserStream(userParam: ""), false),
                        (ElloAPI.UserStream(userParam: currentUserId), false),
                        (ElloAPI.UserStreamFollowers(userId: ""), true),
                        (ElloAPI.UserStreamFollowers(userId: currentUserId), true),
                        (ElloAPI.UserStreamFollowing(userId: ""), true),
                        (ElloAPI.UserStreamFollowing(userId: currentUserId), true),
                        (ElloAPI.UserNameAutoComplete(terms: ""), true)
                    ]
                    for (endpoint, showsNSFW) in expectations {
                        it("\(endpoint) is \(showsNSFW)") {
                            expect(subject.includeNSFW(endpoint, currentUser: currentUser)) == showsNSFW
                        }
                    }
                }
            }
        }
    }
}
