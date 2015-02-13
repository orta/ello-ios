//
//  NotificationCellItemParserSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/13/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class NotificationCellItemParserSpec: QuickSpec {

    var parser : NotificationCellItemParser!

    override func spec() {
        describe("-streamCellItems:") {

            beforeEach {
                self.parser = NotificationCellItemParser()
            }

            it("returns an empty array if an empty array of Activities is passed in") {
                let activities = [Activity]()
                expect(self.parser.postCellItems(activities).count) == 0
            }

            it("returns an empty array if an empty array of Comments is passed in") {
                let comments = [Comment]()
                expect(self.parser.commentCellItems(comments).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                var loadedActivities:[Activity]?

                StreamService().loadStream(ElloAPI.FriendStream, { jsonables in
                    var activities:[Activity] = []
                    for activity in jsonables {
                        if let post = (activity as Activity).subject as? Activity {
                            activities.append(post)
                        }
                    }
                    loadedActivities = activities
                }, failure: nil)

                expect(self.parser.postCellItems(loadedActivities!).count) == 11
            }
        }
    }

}
