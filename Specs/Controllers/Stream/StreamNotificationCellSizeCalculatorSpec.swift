//
//  StreamNotificationCellSizeCalculatorSpec.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class StreamNotificationCellSizeCalculatorSpec : QuickSpec {
    override func spec() {
        describe("sizing NotificationCells") {
            xit("should return minimum size") {
                // no title, no message, no image
            }
            xit("should return reasonable size") {
                // title, no message, no image (same as minimum size)
            }
            xit("should return size that accounts for a message") {
                // title and message
            }
            xit("should return size that accounts for an image") {
                // title and image
            }
            xit("should return very large size") {
                // very long title and very long message
            }
        }
    }
}