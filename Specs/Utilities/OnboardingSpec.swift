//
//  OnboardingSpec.swift
//  Ello
//
//  Created by Colin Gray on 7/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Ello
import SwiftyUserDefaults


class OnboardingSpec: QuickSpec {
    override func spec() {
        let currentVersion: Int? = Defaults["ViewedOnboardingVersion"].int
        afterEach {
            Defaults["ViewedOnboardingVersion"] = currentVersion
        }

        describe("onboarding version has never been set") {
            beforeEach {
                Defaults["ViewedOnboardingVersion"] = nil
            }
            it("should show onboarding") {
                expect(Onboarding.shared().hasSeenLatestVersion()).to(beFalse())
            }
        }
        describe("onboarding version has been set to older version") {
            beforeEach {
                Defaults["ViewedOnboardingVersion"] = 0
            }
            it("should show onboarding") {
                expect(Onboarding.shared().hasSeenLatestVersion()).to(beFalse())
            }
        }
        describe("onboarding version has been set to current version") {
            beforeEach {
                Onboarding.shared().updateVersionToLatest()
            }
            it("should not show onboarding") {
                expect(Onboarding.shared().hasSeenLatestVersion()).to(beTrue())
            }
        }
    }
}
