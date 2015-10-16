//
//  PreloaderSpec.swift
//  Ello
//
//  Created by Sean on 4/28/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class PreloaderSpec: QuickSpec {
    override func spec() {
        var subject: Preloader!
        var mdpi: Attachment!
        var hdpi: Attachment!
        var regular: Attachment!
        var asset: Asset!
        var imageRegion: ImageRegion!
        var oneImagePost: Post!
        var imagePostWithSummary: Post!
        var twoImagePost: Post!
        var threeImagePost: Post!
        var oneImageComment: Comment!
        var threeImageComment: Comment!
        var user1: User!
        var user2: User!
        var user3: User!
        var avatarAsset1: Asset!
        var avatarAsset2: Asset!
        var avatarAsset3: Asset!

        let fakeManager = FakeImageManager()

        beforeEach {
            subject = Preloader()
            fakeManager.reset()
            subject.manager = fakeManager

            mdpi = Attachment.stub([
                "url" : NSURL(string: "http://www.example.com/mdpi.jpg")!,
                "height" : 2, "width" : 5, "type" : "jpeg", "size" : 45644
            ])

            hdpi = Attachment.stub([
                "url" : NSURL(string: "http://www.example.com/hdpi.jpg")!,
                "height" : 2, "width" : 5, "type" : "jpeg", "size" : 45644
            ])

            regular = Attachment.stub([
                "url" : NSURL(string: "http://www.example.com/regular.jpg")!,
                "height" : 60, "width" : 60, "type" : "jpeg", "size" : 45644
            ])

            asset = Asset.stub([
                "id" : "qwerty", "hdpi" : hdpi, "mdpi" : mdpi
            ])

            imageRegion = ImageRegion.stub([
                "asset" : asset,
                "alt" : "some-altness",
                "url" : NSURL(string: "http://www.example.com/url.jpg")!
            ])

            avatarAsset1 = Asset.stub([
                "id" : "1234", "regular" : regular
            ])

            avatarAsset2 = Asset.stub([
                "id" : "431", "regular" : regular
            ])

            avatarAsset3 = Asset.stub([
                "id" : "0000", "regular" : regular
            ])

            user1 = User.stub([
                "id" : "fake-user-1",
                "avatar" : avatarAsset1
            ])

            user2 = User.stub([
                "id" : "fake-user-2",
                "avatar" : avatarAsset2
            ])

            user3 = User.stub([
                "id" : "fake-user-3",
                "avatar" : avatarAsset3
            ])

            oneImagePost = Post.stub([
                "id" : "768",
                "content" : [imageRegion],
                "author" : user1
            ])

            imagePostWithSummary = Post.stub([
                "id" : "9159",
                "content" : [imageRegion, imageRegion],
                "summary" : [imageRegion],
                "author" : user1
            ])

            twoImagePost = Post.stub([
                "id" : "888",
                "content" : [imageRegion, imageRegion],
                "author" : user2
            ])

            threeImagePost = Post.stub([
                "id" : "999",
                "content" : [imageRegion, imageRegion, imageRegion],
                "author" : user3
            ])

            oneImageComment = Comment.stub([
                "id" : "9",
                "content" : [imageRegion],
                "author" : user1
            ])

            threeImageComment = Comment.stub([
                "id" : "11",
                "content" : [imageRegion, imageRegion, imageRegion],
                "author" : user3
            ])
        }

        describe("preloadImages(_:streamKind:)") {

            it("preloads activity image assets and avatars") {

                let activityOne: Activity = stub([
                    "subject" : oneImagePost,
                    "id" : "123",
                ])

                let activityTwo: Activity = stub([
                    "subject" : twoImagePost,
                    "id" : "345",
                ])

                subject.preloadImages([activityOne, activityTwo], streamKind: StreamKind.Following)

                expect(fakeManager.downloads.count) == 5
            }

            it("preloads posts image assets and avatars") {
                subject.preloadImages([oneImagePost, twoImagePost, threeImagePost], streamKind: StreamKind.Following)

                expect(fakeManager.downloads.count) == 9
            }

            it("preloads comments image assets and avatars") {
                subject.preloadImages([oneImageComment, threeImageComment], streamKind: StreamKind.Following)

                expect(fakeManager.downloads.count) == 6
            }

            it("preloads user's posts image assets and avatars") {
                let user: User = stub([
                    "id" : "fake-id",
                    "avatar" : avatarAsset1,
                    "posts" : [twoImagePost, threeImagePost]
                ])

                subject.preloadImages([user], streamKind: StreamKind.Profile(perPage: 10))

                expect(fakeManager.downloads.count) == 8
            }

            it("loads hdpi for single column StreamKinds") {
                subject.preloadImages([oneImagePost], streamKind: StreamKind.Following)

                // grab the second image, first is the avatar of post's author
                expect(fakeManager.downloads[1].absoluteString) == "http://www.example.com/hdpi.jpg"
            }

            it("loads mdpi for grid layout StreamKinds") {
                subject.preloadImages([imagePostWithSummary], streamKind: StreamKind.Noise)

                // grab the second image, first is the avatar of post's author
                expect(fakeManager.downloads[1].absoluteString) == "http://www.example.com/mdpi.jpg"
            }

            it("loads regular for avatars") {
                let user: User = stub([
                    "id" : "fake-regular-id",
                    "avatar" : avatarAsset1,
                ])

                subject.preloadImages([user], streamKind: StreamKind.PostDetail(postParam: "fake-id"))

                expect(fakeManager.downloads.first?.absoluteString) == "http://www.example.com/regular.jpg"
            }
        }
    }
}
