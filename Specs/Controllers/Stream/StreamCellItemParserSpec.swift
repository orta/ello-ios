//
//  StreamCellItemParserSpec.swift
//  Ello
//
//  Created by Sean on 2/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class StreamCellItemParserSpec: QuickSpec {

    var parser: StreamCellItemParser!

    override func spec() {

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
                StreamService().loadStream(ElloAPI.FriendStream, streamKind: nil,
                    success: { (jsonables, responseConfig) in
                        loadedPosts = self.parser.parse(jsonables, streamKind: .Friend)
                    },
                    failure: nil
                )
                expect(loadedPosts.count) == 8
            }

            it("returns an empty array if an empty array of Activities is passed in") {
                let activities = [Notification]()
                expect(self.parser.parse(activities, streamKind: .Notifications).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                var loadedNotifications = [StreamCellItem]()
                StreamService().loadStream(ElloAPI.NotificationsStream, streamKind: nil,
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
