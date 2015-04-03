//
//  DateExtensionSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class DateExtensionSpec: QuickSpec {
    override func spec() {

        describe("-distanceOfTimeInWords:") {

            let now = NSDate()
            let three_seconds_ago = NSDate(timeIntervalSinceNow: -3)
            let five_seconds_ago = NSDate(timeIntervalSinceNow: -5)
            let ten_seconds_ago = NSDate(timeIntervalSinceNow: -10)
            let nineteen_seconds_ago = NSDate(timeIntervalSinceNow: -19)
            let twenty_five_seconds_ago = NSDate(timeIntervalSinceNow: -25)
            let forty_five_seconds_ago = NSDate(timeIntervalSinceNow: -45)
            let sixty_seconds_ago = NSDate(timeIntervalSinceNow: -60)
            let twelve_minutes_ago = NSDate(timeIntervalSinceNow: -60*12)
            let forty_four_minutes_ago = NSDate(timeIntervalSinceNow: -60*44)
            let forty_five_minutes_ago = NSDate(timeIntervalSinceNow: -60*45)
            let twenty_three_hours_forty_five_minutes_ago = NSDate(timeIntervalSinceNow: -85500.0)
            let one_day_ago = NSDate(timeIntervalSinceNow: -86400.0)
            let fifteen_days_ago = NSDate(timeIntervalSinceNow: -86400.0 * 15)

            it("<5s") {
                expect(three_seconds_ago.distanceOfTimeInWords(now)) == "<5s"
            }

            it("<10s") {
                expect(five_seconds_ago.distanceOfTimeInWords(now)) == "<10s"
            }

            it("<20s") {
                expect(ten_seconds_ago.distanceOfTimeInWords(now)) == "<20s"
            }

            it("<20s") {
                expect(nineteen_seconds_ago.distanceOfTimeInWords(now)) == "<20s"
            }

            it("~30s") {
                expect(twenty_five_seconds_ago.distanceOfTimeInWords(now)) == "~30s"
            }

            it("<1m") {
                expect(forty_five_seconds_ago.distanceOfTimeInWords(now)) == "<1m"
            }

            it("~1m") {
                expect(sixty_seconds_ago.distanceOfTimeInWords(now)) == "~1m"
            }

            it("12m") {
                expect(twelve_minutes_ago.distanceOfTimeInWords(now)) == "12m"
            }

            it("44m") {
                expect(forty_four_minutes_ago.distanceOfTimeInWords(now)) == "44m"
            }

            it("~1h") {
                expect(forty_five_minutes_ago.distanceOfTimeInWords(now)) == "~1h"
            }

            it("~23h") {
                expect(twenty_three_hours_forty_five_minutes_ago.distanceOfTimeInWords(now)) == "~23h"
            }

            it("1d") {
                expect(one_day_ago.distanceOfTimeInWords(now)) == "1d"
            }

            it("15d") {
                expect(fifteen_days_ago.distanceOfTimeInWords(now)) == "15d"
            }
        }
    }
}
