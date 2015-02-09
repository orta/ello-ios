//
//  StreamServiceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Quick
import Moya
import Nimble

class StreamServiceSpec: QuickSpec {
    override func spec() {
        describe("-loadStream") {

            var streamService = StreamService()

            context("success") {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }
                
                describe("-loadStream") {
                    
                    it("Calls success with an array of Activity objects") {
                        var loadedStreamables:[Streamable]?

                        streamService.loadStream(ElloAPI.FriendStream, { (streamables) -> () in
                            loadedStreamables = streamables
                        }, failure: nil)

                        expect(countElements(loadedStreamables!)) == 24

                        let post0:Post = loadedStreamables![0] as Post

                        expect(post0.postId) == "4718"
                        expect(post0.href) == "/api/edge/posts/4718"
                        expect(post0.token) == "_axtKV8Q-MSWbUCWjGqykg"
                        expect(post0.collapsed) == false
                        expect(post0.viewsCount) == 6
                        expect(post0.commentsCount) == 50
                        expect(post0.repostsCount) == 3

                        let textBlock:TextBlock = post0.content![0] as TextBlock

                        expect(textBlock.content) == "etest post to determine what happens when someone sees this for the first time as a repost from someone they follow. dcdoran will repost this."

                        let post0Author:User = post0.author!
                        expect(post0Author.userId) == "27"
                        expect(post0Author.href) == "/api/edge/users/27"
                        expect(post0Author.username) == "dcdoran"
                        expect(post0Author.name) == "Sterling"
                        expect(post0Author.experimentalFeatures) == true
                        expect(post0Author.relationshipPriority) == "friend"
                        expect(post0Author.avatarURL!.absoluteString) == "https://d1qqdyhbrvi5gr.cloudfront.net/uploads/user/avatar/27/large_ello-09fd7088-2e4f-4781-87db-433d5dbc88a5.png"
                    }

                    it("handles assets") {
                        var loadedStreamables:[Streamable]?

                        streamService.loadStream(ElloAPI.FriendStream, { streamables in
                            loadedStreamables = streamables
                        }, failure: nil)

                        let post2:Post = loadedStreamables![2] as Post

                        expect(post2.postId) == "4707"

                        let imageBlock:ImageBlock = post2.content![0] as ImageBlock

                        expect(imageBlock.hdpi).notTo(beNil())
                        expect(imageBlock.hdpi!.width) == 750
                        expect(imageBlock.hdpi!.height) == 321
                        expect(imageBlock.hdpi!.size) == 77464
                        expect(imageBlock.hdpi!.imageType) == "image/jpeg"
                    }
                }

                describe("-loadMoreCommentsForPost") {
                    
                    it("calls success with an array of Comment objects", {
                        var loadedStreamables:[Streamable]?

                        streamService.loadMoreCommentsForPost("111", success: { (streamables) -> () in
                            loadedStreamables = streamables
                        }, failure:nil)

                        expect(countElements(loadedStreamables!)) == 1

                        let expectedCreatedAt = "2014-06-02T00:00:00.000Z".toNSDate()!
                        let comment:Comment = loadedStreamables![0] as Comment

                        expect(comment.commentId) == "112"
                        expect(comment.createdAt) == expectedCreatedAt

                        let contentBlock0:TextBlock = comment.content![0] as TextBlock
                        expect(contentBlock0.content) == "<p>Hello, I am a comment with awesome content!</p>"

                        let commentAuthor:User = comment.author!

                        expect(commentAuthor).to(beAnInstanceOf(User.self))
                        expect(commentAuthor.name) == "Pamilanderson"
                        expect(commentAuthor.userId) == "345"
                        expect(commentAuthor.username) == "pam"
                        expect(commentAuthor.href) == "/api/edge/users/345"
                        expect(commentAuthor.experimentalFeatures) == true
                        expect(commentAuthor.avatarURL!.absoluteString) == "https://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/97143/regular_owl.png"
                    })
                }
            }

            context("failure") {

                // smoke test a few failure status codes, the whole lot is tested in ElloProviderSpec

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                context("404") {

                    beforeEach {
                        ElloProvider.errorStatusCode = .Status404
                    }

                    it("Calls failure with an error and statusCode") {

                        var loadedStreamables:[Streamable]?
                        var loadedStatusCode:Int?
                        var loadedError:NSError?

                        streamService.loadStream(ElloAPI.FriendStream, { (streamables) -> () in
                            loadedStreamables = streamables
                        }, failure: { (error, statusCode) -> () in
                            loadedError = error
                            loadedStatusCode = statusCode
                        })

                        expect(loadedStreamables).to(beNil())
                        expect(loadedStatusCode!) == 404
                        expect(loadedError!).notTo(beNil())

                        let elloNetworkError = loadedError!.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError

                        expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
                        expect(elloNetworkError.code) == ElloNetworkError.CodeType.notFound
                        expect(elloNetworkError.title) == "The requested resource could not be found."
                        expect(elloNetworkError.status) == "404"
                    }
                }
            }

        }
    }
}
