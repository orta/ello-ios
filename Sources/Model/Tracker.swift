//
//  Tracker.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/9/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Analytics
import Keys

public enum ContentType: String {
    case Post = "Post"
    case Comment = "Comment"
}

public protocol AnalyticsAgent {
    func identify(userId: String!, traits: [NSObject : AnyObject]!)
    func track(event: String!)
    func screen(screenTitle: String!)
    func reset()
}

public struct NullAgent: AnalyticsAgent {
    public func identify(userId: String!, traits: [NSObject : AnyObject]!) { }
    public func track(event: String!) { }
    public func screen(screenTitle: String!) { }
    public func reset() { }
}

extension SEGAnalytics: AnalyticsAgent { }

public struct Tracker {
    public static let sharedTracker = Tracker()

    private var shouldTrackUser = true
    private var agent: AnalyticsAgent {
        return shouldTrackUser ? SEGAnalytics.sharedAnalytics() : NullAgent()
    }

    public init() {
        let configuration = SEGAnalyticsConfiguration(writeKey: ElloKeys().segmentKey())
         SEGAnalytics.setupWithConfiguration(configuration)
    }
}

public extension Tracker {
    func identify(user: User) {
        // set the user's tracking preference to `shouldTrackUser`
        agent.identify(user.analyticsId, traits: [ "name": user.name ])
    }
}

public extension Tracker {
    func sessionStarted() { }
    func sessionEnded() { }

    func screenAppeared(name: String) { }

    func contentCreated(type: ContentType) { }
    func contentCreationCanceled(type: ContentType) { }
    func contentCreationFailed(type: ContentType, message: String) { }

    func contentFlagged(type: ContentType, flag: ContentFlagger.AlertOption) { }
    func contentFlaggingCanceled(type: ContentType) { }
    func contentFlaggingFailed(type: ContentType, message: String) { }

    func viewedImage() { }

    func postBarVisibilityChanged(visible: Bool) { }
    func postReposted() { }
    func postShared() { }
    func postLoved() { }

    func commentBarVisibilityChanged(visible: Bool) { }

    func userBlocked() { }
    func userMuted() { }
    func userBlockCanceled() { }

    func imageAddedFromCamera() { }
    func imageAddedFromLibrary() { }
    func addImageCanceled() { }

    func inviteFriendsTapped() { }
    func friendAdded() { }
    func noiseAdded() { }
    func friendInvited() { }
    func importContactsInitiated() { }
    func importContactsDenied() { }
    func addressBookAccessed() { }

    func pushNotificationPreferenceChanged(enabled: Bool) { }
    func contactAccessPreferenceChanged(enabled: Bool) { }

    func drawerClosed() { }

    func viewsButtonTapped() { }

    func encounteredNetworkError(error: NSError) { }
}
