//
//  SpecsTrackingAgent.swift
//  Ello
//
//  Created by Sean on 10/2/15.
//  Copyright © 2015 Ello. All rights reserved.
//

import Ello

public class SpecsTrackingAgent: AnalyticsAgent {

    public var resetCalled = false
    public var lastEvent = ""
    public var lastUserId = ""
    public var lastTraits: [NSObject : AnyObject] = [:]
    public var lastScreenTitle = ""
    public var lastProperties: [NSObject: AnyObject] = [:]

    public func identify(userId: String!, traits: [NSObject : AnyObject]!) {
        lastUserId = userId
        lastTraits = traits
    }

    public func track(event: String!) {
        lastEvent = event
    }

    public func track(event: String!, properties: [NSObject: AnyObject]!) {
        lastEvent = event
        lastProperties = properties
    }

    public func screen(screenTitle: String!) {
        lastScreenTitle = screenTitle
    }

    public func screen(screenTitle: String!, properties: [NSObject: AnyObject]!) {
        lastScreenTitle = screenTitle ?? ""
        lastProperties = properties ?? [:]
    }

    public func reset() {
        resetCalled = true
    }
}
