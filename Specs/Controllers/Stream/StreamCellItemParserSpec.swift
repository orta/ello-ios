//
//  StreamCellItemParserSpec.swift
//  Ello
//
//  Created by Sean on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class StreamCellItemParserSpec: QuickSpec {

    var parser: StreamCellItemParser!

    override func spec() {

        describe("-aspectRatioForImageBlock:") {

            it("returns 4/3 if width or height not present") {
                let imageBlock = ImageRegion(asset:nil, alt: "alt text", url:NSURL(string: "http://www.ello.com"))
                let aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageBlock)

                expect(aspectRatio) == 4.0/3.0
            }

            it("returns the correct aspect ratio") {
                let hdpi = ImageAttachment(url: NSURL(string: "http://www.ello.com"), height: 1600, width: 900, imageType: "jpeg", size: 894578)
                var asset = Asset(assetId: "123", hdpi: hdpi, xxhdpi: nil)
                var imageBlock = ImageRegion(asset:asset, alt: "alt text", url:NSURL(string: "http://www.ello.com"))
                let aspectRatio = StreamCellItemParser.aspectRatioForImageBlock(imageBlock)

                expect(aspectRatio) == 900.0/1600.0
            }
        }

        describe("-streamCellItems:") {

            beforeEach {
                self.parser = StreamCellItemParser()
            }

            it("returns an empty array if an empty array of Posts is passed in") {
                let posts = [Post]()
                expect(self.parser.postCellItems(posts, streamKind: .Friend).count) == 0
            }

            it("returns an empty array if an empty array of Comments is passed in") {
                let comments = [Comment]()
                expect(self.parser.commentCellItems(comments).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's posts") {
                var loadedPosts:[Post]?

                StreamService().loadStream(ElloAPI.FriendStream, { jsonables in
                    var posts:[Post] = []
                    for activity in jsonables {
                        if let post = (activity as Activity).subject as? Post {
                            posts.append(post)
                        }
                    }
                    loadedPosts = posts
                }, failure: nil)

                expect(self.parser.postCellItems(loadedPosts!, streamKind: .Friend).count) == 11
            }
        }
    }

}
