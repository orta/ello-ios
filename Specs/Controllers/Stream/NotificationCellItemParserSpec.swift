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
                let activities = [Notification]()
                expect(self.parser.cellItems(activities).count) == 0
            }

            it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                var loadedNotifications:[Notification]?

                NotificationsService().load(success: { notifications in
                    loadedNotifications = notifications
                }, failure: nil)

                expect(self.parser.cellItems(loadedNotifications!).count) == loadedNotifications!.count
            }

        }
    }

}
