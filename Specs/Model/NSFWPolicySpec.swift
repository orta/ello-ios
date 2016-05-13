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

        fdescribe("NSFWPolicy") {
            describe("includeNSFW(_:)") {
                context("current user DOES view nsfw") {
                    let currentUserId = "123"
                    let currentUsername = "bob"
                    let currentUser: User = stub(["id" : currentUserId, "username": currentUsername, "viewsAdultContent": true, "profile": Profile.stub(["email": "some@guy.com"])])
                    let expectations = [
                        (.AmazonCredentials, false),
                        (.AnonymousCredentials, false),
                        (.Auth(email: "", password: ""), false),
                        (.Availability(content: ["":""]), false),
                        (.AwesomePeopleStream, false),
                        (.CommentDetail(postId: "", commentId: ""), false),
                        (.CommunitiesStream, false),
                        (.CreateComment(parentPostId: "", body: ["": ""]), false),
                        (.CreateLove(postId: ""), false),
                        (.CreatePost(body: ["": ""]), false),
                        (.CurrentUserProfile, true),
                        (.CurrentUserStream, true),
                        (.DeleteComment(postId: "", commentId: ""), false),
                        (.DeleteLove(postId: ""), false),
                        (.DeletePost(postId: ""), false),
                        (.DeleteSubscriptions(token: NSData()), false),
                        (.Discover(type: .Recommended, perPage: 0), false),
                        (.Discover(type: .Trending, perPage: 0), false),
                        (.Discover(type: .Recent, perPage: 0), false),
                        (.EmojiAutoComplete(terms: ""), false),
                        (.FindFriends(contacts: ["": [""]]), false),
                        (.FlagComment(postId: "", commentId: "", kind: ""), false),
                        (.FlagPost(postId: "", kind: ""), false),
                        (.FriendStream, true),
                        (.FriendNewContent(createdAt: NSDate()), true),
                        (.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                        (.InviteFriends(contact: ""), false),
                        (.Join(email: "", username: "", password: "", invitationCode: ""), false),
                        (.Loves(userId: ""), false),
                        (.Loves(userId: currentUserId), true),
                        (.Loves(userId: "~\(currentUsername)"), true),
                        (.NoiseStream, true),
                        (.NoiseNewContent(createdAt: NSDate()), true),
                        (.NotificationsNewContent(createdAt: NSDate()), true),
                        (.NotificationsStream(category: ""), true),
                        (.PostComments(postId: ""), false),
                        (.PostDetail(postParam: "", commentCount: 0), true),
                        (.PostLovers(postId: ""), false),
                        (.PostReposters(postId: ""), false),
                        (.ProfileDelete, false),
                        (.ProfileToggles, false),
                        (.ProfileUpdate(body: ["": ""]), false),
                        (.PushSubscriptions(token: NSData()), false),
                        (.ReAuth(token: ""), false),
                        (.RePost(postId: ""), false),
                        (.Relationship(userId: "", relationship: ""), false),
                        (.RelationshipBatch(userIds: [""], relationship: ""), false),
                        (.SearchForUsers(terms: ""), false),
                        (.SearchForPosts(terms: ""), false),
                        (.UpdatePost(postId: "", body: ["": ""]), false),
                        (.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                        (.UserStream(userParam: ""), true),
                        (.UserStream(userParam: currentUserId), true),
                        (.UserStream(userParam: "~\(currentUsername)"), true),
                        (.UserStreamFollowers(userId: ""), true),
                        (.UserStreamFollowing(userId: ""), true),
                        (.UserNameAutoComplete(terms: ""), true)
                    ]
                    for (endpoint, showsNSFW) in expectations {
                        it("\(endpoint) is \(showsNSFW)") {
                            expect(subject.includeNSFW(endpoint, currentUser: currentUser)) == showsNSFW
                        }
                    }
                }

                context("current user DOES NOT view nsfw") {
                    let currentUserId = "123"
                    let currentUsername = "bob"
                    let currentUser: User = stub(["id" : currentUserId, "username": currentUsername, "viewsAdultContent": false, "profile": Profile.stub(["email": "some@guy.com"])])
                    let expectations = [
                        (.AmazonCredentials, false),
                        (.AnonymousCredentials, false),
                        (.Auth(email: "", password: ""), false),
                        (.Availability(content: ["":""]), false),
                        (.AwesomePeopleStream, false),
                        (.CommentDetail(postId: "", commentId: ""), false),
                        (.CommunitiesStream, false),
                        (.CreateComment(parentPostId: "", body: ["": ""]), false),
                        (.CreateLove(postId: ""), false),
                        (.CreatePost(body: ["": ""]), false),
                        (.CurrentUserProfile, true),
                        (.CurrentUserStream, true),
                        (.DeleteComment(postId: "", commentId: ""), false),
                        (.DeleteLove(postId: ""), false),
                        (.DeletePost(postId: ""), false),
                        (.DeleteSubscriptions(token: NSData()), false),
                        (.Discover(type: .Recommended, perPage: 0), false),
                        (.Discover(type: .Trending, perPage: 0), false),
                        (.Discover(type: .Recent, perPage: 0), false),
                        (.EmojiAutoComplete(terms: ""), false),
                        (.FindFriends(contacts: ["": [""]]), false),
                        (.FlagComment(postId: "", commentId: "", kind: ""), false),
                        (.FlagPost(postId: "", kind: ""), false),
                        (.FriendStream, false),
                        (.FriendNewContent(createdAt: NSDate()), false),
                        (.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                        (.InviteFriends(contact: ""), false),
                        (.Join(email: "", username: "", password: "", invitationCode: ""), false),
                        (.Loves(userId: ""), false),
                        (.Loves(userId: currentUserId), true),
                        (.Loves(userId: "~\(currentUsername)"), true),
                        (.NoiseStream, false),
                        (.NoiseNewContent(createdAt: NSDate()), false),
                        (.NotificationsNewContent(createdAt: NSDate()), true),
                        (.NotificationsStream(category: ""), true),
                        (.PostComments(postId: ""), false),
                        (.PostDetail(postParam: "", commentCount: 0), false),
                        (.PostLovers(postId: ""), false),
                        (.PostReposters(postId: ""), false),
                        (.ProfileDelete, false),
                        (.ProfileToggles, false),
                        (.ProfileUpdate(body: ["": ""]), false),
                        (.PushSubscriptions(token: NSData()), false),
                        (.ReAuth(token: ""), false),
                        (.RePost(postId: ""), false),
                        (.Relationship(userId: "", relationship: ""), false),
                        (.RelationshipBatch(userIds: [""], relationship: ""), false),
                        (.SearchForUsers(terms: ""), false),
                        (.SearchForPosts(terms: ""), false),
                        (.UpdatePost(postId: "", body: ["": ""]), false),
                        (.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                        (.UserStream(userParam: ""), false),
                        (.UserStream(userParam: currentUserId), true),
                        (.UserStream(userParam: "~\(currentUsername)"), true),
                        (.UserStreamFollowers(userId: ""), true),
                        (.UserStreamFollowers(userId: currentUserId), true),
                        (.UserStreamFollowing(userId: ""), true),
                        (.UserStreamFollowing(userId: currentUserId), true),
                        (.UserNameAutoComplete(terms: ""), true)
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
                    let currentUsername = "bob"
                    let currentUser: User = stub(["id" : currentUserId, "username": currentUsername, "viewsAdultContent": false, "profile": Profile.stub(["email": "some@guy.com"])])

                    let expectations = [
                        (.AmazonCredentials, false),
                        (.AnonymousCredentials, false),
                        (.Auth(email: "", password: ""), false),
                        (.Availability(content: ["":""]), false),
                        (.AwesomePeopleStream, false),
                        (.CommentDetail(postId: "", commentId: ""), false),
                        (.CommunitiesStream, false),
                        (.CreateComment(parentPostId: "", body: ["": ""]), false),
                        (.CreateLove(postId: ""), false),
                        (.CreatePost(body: ["": ""]), false),
                        (.CurrentUserProfile, true),
                        (.CurrentUserStream, true),
                        (.DeleteComment(postId: "", commentId: ""), false),
                        (.DeleteLove(postId: ""), false),
                        (.DeletePost(postId: ""), false),
                        (.DeleteSubscriptions(token: NSData()), false),
                        (.Discover(type: .Recommended, perPage: 0), false),
                        (.Discover(type: .Trending, perPage: 0), false),
                        (.Discover(type: .Recent, perPage: 0), false),
                        (.EmojiAutoComplete(terms: ""), false),
                        (.FindFriends(contacts: ["": [""]]), false),
                        (.FlagComment(postId: "", commentId: "", kind: ""), false),
                        (.FlagPost(postId: "", kind: ""), false),
                        (.FriendStream, false),
                        (.FriendNewContent(createdAt: NSDate()), false),
                        (.InfiniteScroll(queryItems: [""], elloApi: { return ElloAPI.AwesomePeopleStream }), false),
                        (.InviteFriends(contact: ""), false),
                        (.Join(email: "", username: "", password: "", invitationCode: ""), false),
                        (.Loves(userId: ""), false),
                        (.Loves(userId: currentUserId), false),
                        (.Loves(userId: "~\(currentUsername)"), false),
                        (.NoiseStream, false),
                        (.NoiseNewContent(createdAt: NSDate()), false),
                        (.NotificationsNewContent(createdAt: NSDate()), true),
                        (.NotificationsStream(category: ""), true),
                        (.PostComments(postId: ""), false),
                        (.PostDetail(postParam: "", commentCount: 0), false),
                        (.PostLovers(postId: ""), false),
                        (.PostReposters(postId: ""), false),
                        (.ProfileDelete, false),
                        (.ProfileToggles, false),
                        (.ProfileUpdate(body: ["": ""]), false),
                        (.PushSubscriptions(token: NSData()), false),
                        (.ReAuth(token: ""), false),
                        (.RePost(postId: ""), false),
                        (.Relationship(userId: "", relationship: ""), false),
                        (.RelationshipBatch(userIds: [""], relationship: ""), false),
                        (.SearchForUsers(terms: ""), false),
                        (.SearchForPosts(terms: ""), false),
                        (.UpdatePost(postId: "", body: ["": ""]), false),
                        (.UpdateComment(postId: "", commentId: "", body: ["": ""]), false),
                        (.UserStream(userParam: ""), false),
                        (.UserStream(userParam: currentUserId), false),
                        (.UserStream(userParam: "~\(currentUsername)"), false),
                        (.UserStreamFollowers(userId: ""), true),
                        (.UserStreamFollowers(userId: currentUserId), true),
                        (.UserStreamFollowing(userId: ""), true),
                        (.UserStreamFollowing(userId: currentUserId), true),
                        (.UserNameAutoComplete(terms: ""), true)
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
