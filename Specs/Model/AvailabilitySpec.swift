//
//  AvailabilitySpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/31/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble

class AvailabilitySpec: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let parsedAvailability = stubbedJSONData("availability", "availability")
            let availability = Availability.fromJSON(parsedAvailability) as! Availability

            expect(availability.username).to(beFalse())
            expect(availability.email).to(beTrue())
            expect(availability.invitationCode).to(beTrue())
            expect(availability.usernameSuggestions.count) == 3
            expect(availability.emailSuggestion) == "lana@gmail.com"
        }
    }
}
