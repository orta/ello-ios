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
                expect(self.parser.parse(posts, streamKind: .Friend).count) == 0
            }

            it("returns an empty array if an empty array of Comments is passed in") {
                let comments = [Comment]()
                expect(self.parser.parse(comments, streamKind: .Friend).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's posts") {
                var loadedPosts = [StreamCellItem]()
                StreamService().loadStream(ElloAPI.FriendStream,
                    success: { (jsonables, responseConfig) in
                        loadedPosts = self.parser.parse(jsonables, streamKind: .Friend)
                    },
                    failure: nil
                )
                expect(loadedPosts.count) == 11
            }

            it("returns an empty array if an empty array of Activities is passed in") {
                let activities = [Notification]()
                expect(self.parser.parse(activities, streamKind: .Notifications).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                var loadedNotifications = [StreamCellItem]()
                StreamService().loadStream(ElloAPI.NotificationsStream,
                    success: { (jsonables, responseConfig) in
                        loadedNotifications = self.parser.parse(jsonables, streamKind: .Notifications)
                    },
                    failure: nil
                )
                expect(loadedNotifications.count) == 9
            }
        }
    }

}
