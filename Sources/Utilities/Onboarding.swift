//
//  Onboarding.swift
//  Ello
//
//  Created by Colin Gray on 7/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyUserDefaults


private let _sharedInstance = Onboarding()
private let _currentVersion = 1

public class Onboarding {
    private var version: Int {
        didSet {
            GroupDefaults["ViewedOnboardingVersion"] = version
        }
    }

    public class func currentVersion() -> Int {
        return _currentVersion
    }

    public func updateVersionToLatest() {
        version = _currentVersion
    }

    public func reset() {
        version = 0
    }

    public class func shared() -> Onboarding {
        return _sharedInstance
    }

    init() {
        version = GroupDefaults["ViewedOnboardingVersion"].int ?? 0
    }

    public func hasSeenLatestVersion() -> Bool {
        return version >= _currentVersion
    }

}
