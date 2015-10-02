//
//  Rate.swift
//  Ello
//
//  Created by Sean on 10/1/15.
//  Copyright © 2015 Ello. All rights reserved.
//

import Foundation
import iRate

public class Rate: NSObject {

    public static let sharedRate = Rate()

    public func setup() {
        iRate.sharedInstance().delegate = self
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
        iRate.sharedInstance().previewMode = false
        iRate.sharedInstance().messageTitle = NSLocalizedString("Love Ello?", comment: "rate app prompt title")
        iRate.sharedInstance().message = ""
        iRate.sharedInstance().updateMessage = ""
        iRate.sharedInstance().rateButtonLabel = NSLocalizedString("Rate us: ⭐️⭐️⭐️⭐️⭐️", comment: "rate app button title")
        iRate.sharedInstance().cancelButtonLabel = NSLocalizedString("No Thanks", comment: "do not rate app button title")
        iRate.sharedInstance().usesUntilPrompt = 3
        iRate.sharedInstance().eventsUntilPrompt = 3
        iRate.sharedInstance().daysUntilPrompt = 7
        iRate.sharedInstance().usesPerWeekForPrompt = 0
        iRate.sharedInstance().remindPeriod = 7
    }

    public func prompt() {
        iRate.sharedInstance().promptForRating()
    }

    public func logEvent() {
        iRate.sharedInstance().logEvent(false)
    }
}

extension Rate: iRateDelegate {
    public func iRateCouldNotConnectToAppStore(error: NSError!){
        Tracker.sharedTracker.ratePromptCouldNotConnectToAppStore()
    }

    public func iRateDidPromptForRating(){
        Tracker.sharedTracker.ratePromptShown()
    }

    public func iRateUserDidAttemptToRateApp(){
        Tracker.sharedTracker.ratePromptUserAttemptedToRateApp()
    }

    public func iRateUserDidDeclineToRateApp(){
        Tracker.sharedTracker.ratePromptUserDeclinedToRateApp()
    }

    public func iRateUserDidRequestReminderToRateApp(){
        Tracker.sharedTracker.ratePromptRemindMeLater()
    }

    public func iRateDidOpenAppStore(){
        Tracker.sharedTracker.ratePromptOpenedAppStore()
    }
}